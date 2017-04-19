class BookingPropertyFacility < ApplicationRecord

	validates_uniqueness_of :hotelfacilitytype_id, scope: :hotel_id
	def self.get_booking_facilities
    client_id = 'triphappy'
    client_secret = 'triphappyapi'
    authorization_header = Base64.strict_encode64("#{client_id}:#{client_secret}")

    offset = 0
    continue = true

		while continue
			url = "https://distribution-xml.booking.com/json/bookings.getHotelFacilities?offset=#{offset}&rows=100"
			response = HTTParty.get(url, headers: {'Authorization' => "Basic #{authorization_header}"})
			puts url

			response.each do |facility|
				t = BookingPropertyFacility.new
				t.provider_id = facility['hotel_id']
				t.hotelfacilitytype_id = facility['hotelfacilitytype_id'] 
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
end
