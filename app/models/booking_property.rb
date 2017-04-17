class BookingProperty < ApplicationRecord
	



	def self.scrape_reviews


	end

	def call_booking(hotel)
		
		hotel_name = hotel.name.gsub(' ','-')
		country_code = hotel.country_code
		offset = 0
		#url for scraping Booking.com reviews
		"https://www.booking.com/reviewlist.en-gb.html?pagename=#{hotel_name};cc1=#{country_code};type=total;score=;offset=0;rows=100"


end
