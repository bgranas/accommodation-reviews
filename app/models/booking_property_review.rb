class BookingPropertyReview < ApplicationRecord
	#belongs_to :booking_property
	validates_uniqueness_of :booking_property_id, scope: [:username, :title, :date]

	def self.scrape_reviews
		hotels = BookingProperty.where(overall_rating: nil).order('id ASC')
		hotels.each do |hotel|
			get_booking_reviews_for_property(hotel)
		end

	end

	def self.get_booking_reviews_for_property(booking_prop_id)
		a = Mechanize.new
		a.user_agent_alias = 'Windows Chrome'

		hotel = BookingProperty.find(booking_prop_id)
			
		#hotel_name = hotel.name.gsub('&amp;', '-and-').gsub('  ',' ').gsub(/[^0-9A-Za-z -]/, '').gsub(' - ','-').gsub(' ','-').gsub('--','-')
		country_code = hotel.country_code
		offset = 0
		continue = true

		while continue
			#url for scraping Booking.com reviews
			url = "https://www.booking.com/reviewlist.en-gb.html?;pagename=#{hotel.pagename};cc1=#{country_code};type=total;score=;offset=#{offset};rows=100"
			puts url
			p = a.get(url)

			reviews = p.search('.review_item')
			reviews.each do |review|
				t = BookingPropertyReview.new

				t.booking_property = booking_prop_id
				t.date = DateTime.parse(review.search('.review_item_date').text)
				t.country = review.search('.reviewer_country').text.squish
				t.username = review.search('.review_item_reviewer h4').text.squish
				t.num_reviews = review.search('.review_item_user_review_count')&.text.partition(' ').first.to_i
				t.overall_rating = review.search('.review_item_review_score').text.to_d
				t.title = review.search('.review_item_header_content')&.text.gsub('"','').squish
				t.pos_text = review.search('.review_pos')&.text.gsub('눇','')
				t.neg_text = review.search('.review_neg')&.text.gsub('눇','')

				if p.search('.review_item_response_container').length > 0
					t.owner_responded = true
				else
					t.owner_responded = false
				end

				t.save
			end
			sleep(1)
			offset += 100
			paginate = p.search('.page_showing').text.squish.partition('- ').last.to_i

			if (paginate % 100) != 0
				continue = false
			end
		end
	end
end
