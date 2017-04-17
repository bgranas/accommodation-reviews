class HwProperty < ApplicationRecord
	has_many :hw_facilities
	has_many :reviews
	has_many :room_types
	has_many :room_availabilities
	validates_uniqueness_of :provider_id

	
	def self.get_subratings
		a = Mechanize.new

		hostels = HwProperty.all.order('is ASC')
		hostels.each do |hostel|
			url = "http://www.hostelworld.com/hosteldetails.php/#{hostel.provider_id}/reviews"
			p = a.get(url)

			if p.search('.ratingbreakdownlist')

				hostel.value_rating = p.search('.ratingbreakdownlist li')[0]&.search('.ratingpercent').text.to_i
				hostel.security_rating = p.search('.ratingbreakdownlist li')[1]&.search('.ratingpercent').text.to_i
				hostel.location_rating = p.search('.ratingbreakdownlist li')[2]&.search('.ratingpercent').text.to_i
				hostel.staff_rating = p.search('.ratingbreakdownlist li')[3]&.search('.ratingpercent').text.to_i
				hostel.atmosphere_rating = p.search('.ratingbreakdownlist li')[4]&.search('.ratingpercent').text.to_i
				hostel.cleanliness_rating = p.search('.ratingbreakdownlist li')[5]&.search('.ratingpercent').text.to_i
				hostel.facilities_rating = p.search('.ratingbreakdownlist li')[6]&.search('.ratingpercent').text.to_i

				hostel.save
			end
		end

	end



	def self.pull_reviews

		hostels = HwProperty.where(id: 11).order('id ASC')

		hostels.each do |hostel|
			review_scraper(hostel)
		end

	end


	def self.review_scraper(hostel)
		a = Mechanize.new

		cont = true
		i = 1

		while cont
			url = h"http://www.hostelworld.com/hosteldetails.php/#{hostel.provider_id}//reviews?lang=all&sortOrder=newest&showOlderReviews=1&page=#{i}#reviewFilters"
			p = a.get(url)
			reviews = p.search('.reviewlisting')
			reviews.each do |review|

				r = Review.new
				
				r.provider = hostel.provider
				r.property_id = hostel.id
				r.review_id = review.search('.reviewtext')[0]['id'].partition('w').last.to_i
				r.username = review.search('.reviewername').text.squish
				r.nationality = review.search('.reviewerdetails').text.split(', ')[0]&.squish
				r.gender = review.search('.reviewerdetails').text.split(', ')[1]&.squish
				r.age = review.search('.reviewerdetails').text.split(', ')[2]&.squish
				r.num_reviews = review.search('.reviewernumber').text.split(' ')[0].squish
				r.text = review.search('.reviewtext p').text
				d = DateTime.parse(review.search('.reviewdate').text.squish)
				r.date = d.strftime('%d/%b/%Y')
				r.overall_rating = review.search('.textrating').text.to_i

				list = review.search('.ratinglist')
				r.value = list[0].search('li span')[0].text
				r.security = list[0].search('li span')[1].text
				r.location = list[0].search('li span')[2].text
				r.facilities = list[0].search('li span')[3].text
				r.staff = list[1].search('li span')[0].text
				r.atmosphere = list[1].search('li span')[1].text
				r.cleanliness = list[1].search('li span')[2].text

				r.save

			end

			if p.search('.pagination-next i.fa-angle-double-right').length > 0
				i += 1
			else
				cont = false
			end
		end
	end
end
