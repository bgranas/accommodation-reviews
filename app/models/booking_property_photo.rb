class BookingPropertyPhoto < ApplicationRecord
	#belongs_to :booking_property

	validates_uniqueness_of :photo_id


		def self.get_booking_photos
	    client_id = 'triphappy'
	    client_secret = 'triphappyapi'

	    authorization_header = Base64.strict_encode64("#{client_id}:#{client_secret}")

			offset = 0
			continue = true
			while continue
				url = "https://distribution-xml.booking.com/json/bookings.getHotelPhotos?offset=#{offset}&rows=100"
				response = HTTParty.get(url, headers: {'Authorization' => "Basic #{authorization_header}"})
				puts response
				response.each do |photo|
					t = BookingPropertyPhoto.new

					t.provider_id = photo['hotel_id']
					t.photo_id = photo['photo_id']
					t.url_small = photo['url_square60']
					t.url_medium = photo['url_max300']
					t.url_large = photo['url_original']

					t.save
				end
				if response.length == 1000
					offset += 1000
				else
					continue = false
				end
			end
		end
end
