module BookingHelper
	
	include HTTParty
	
	class BookingProperty
		def self.get_all_booking_properties
			
			offset = 0
			continue = true

	    client_id = 'triphappy'
	    client_secret = 'triphappyapi'

	    authorization_header = Base64.strict_encode64("#{client_id}:#{client_secret}")
			
			while continue
				
				url = "https://distribution-xml.booking.com/json/bookings.getHotels?offset=#{offset}&rows=1000&languagecode=en"
				response = HTTParty.get(url, headers: {'Authorization' => "Basic #{authorization_header}"})
				
				response.each do |hotel|
					t = BookingProperty.new

					t.provider_id = hotel['hotel_id']
		    	t.name = hotel['name']
		    	t.overall_rating = hotel['review_score']&.to_d
		    	t.review_count = hotel['review_nr']
		    	t.address = hotel['address']
		    	t.city = hotel['city']
		    	t.provider_city_id = hotel['city_id']
		    	t.country_code = hotel['countrycode']
		    	t.property_type = hotel['hoteltype_id']
		    	t.base_currency = hotel['currencycode']
		    	t.lat = hotel['location']['latitude']
		    	t.lng = hotel['location']['longitude']
		    	t.star_rating = hotel['class']
		    	t.creation_date = hotel['created']
		    	t.max_people_per_booking = hotel['max_persons_in_reservation']
		    	t.min_rate = hotel['minrate']
		    	t.max_rate = hotel['maxrate']
		    	t.nr_rooms = hotel['nr_rooms']
		    	t.url = hotel['url']

		    	t.save
				end
				puts 'OFFSET: ' + offset.to_s

				if response.length == 1000
					offset += 1000
				else
					continue = false
				end
			end
		end

		def self.get_booking_photos

		end

		def self.get_booking_facilities
	    client_id = 'triphappy'
	    client_secret = 'triphappyapi'

	    authorization_header = Base64.strict_encode64("#{client_id}:#{client_secret}")
			url = "https://distribution-xml.booking.com/json/bookings.getHotelFacilityTypes"
			response = HTTParty.get(url, headers: {'Authorization' => "Basic #{authorization_header}"})

			response.each do |f|
				puts f['hotelfacilitytype_id'].to_s + "," + f['name'].to_s
			end
		end

		def self.get_booking_descriptions
		end

		def self.scrape_reviews
			hotels = BookingProperty.where(overall_rating: nil).order('id ASC')
			hotels.each do |hotel|
				get_booking_reviews_for_property(hotel)
			end

		end

		def self.get_booking_reviews_for_property(hotel)
			
			hotel_name = hotel.name.gsub(' ','-')
			country_code = hotel.country_code
			offset = 0
			#url for scraping Booking.com reviews
			"https://www.booking.com/reviewlist.en-gb.html?pagename=#{hotel_name};cc1=#{country_code};type=total;score=;offset=0;rows=100"

		end
	end
end
