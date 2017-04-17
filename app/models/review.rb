class Review < ApplicationRecord
	belongs_to :hw_property

	validates_uniqueness_of :review_id

	def self.pull_reviews(city_id)

		hostels = HwProperty.where(provider_city_id: city_id).where('id > ?', 6953).order('id ASC') #id = 3864

		hostels.each do |hostel|
			review_scraper(hostel)
		end

	end


	def self.review_scraper(hostel)
		a = Mechanize.new

		cont = true
		i = 1

		while cont
			hostel_formatted = hostel.name.gsub(' - ','-').gsub('&amp;','and').gsub(' ','-').gsub('\'','-').gsub(',','')
			url = "http://www.hostelworld.com/hosteldetails.php/#{hostel_formatted}/#{hostel.city}/#{hostel.provider_id}/reviews?lang=all&sortOrder=newest&showOlderReviews=1&page=#{i}#reviewFilters"
			puts "******PAGE: " + url.to_s
			p = a.get(url)
			reviews = p.search('.reviewlisting')
			reviews.each do |review|

				r = Review.new
				
				r.hw_property_id = hostel.id
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
				i = i + 1
			else
				cont = false
			end

			sleep(1)
		end
	end

	def self.median(array)
	  sorted = array.sort
	  len = sorted.length
	  (sorted[(len - 1) / 2] + sorted[len / 2]) / 2.0
	end

end
