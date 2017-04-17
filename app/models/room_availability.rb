class RoomAvailability < ApplicationRecord
	belongs_to :hw_property

	include HTTParty

		def self.get_room_availability(provider_id)
		hostels = HwProperty.where(provider_city_id: provider_id).order('id ASC')
		check_in = "2017-04-17"
		check_out = "2017-04-18"
		hostels.each do |hostel|
			url = "http://www.hostelworld.com/microsite/get-availability?dateFrom=#{check_in}&dateTo=#{check_out}&propNum=#{hostel.provider_id}&number_of_guests=1"
			puts url.to_s
			response = HTTParty.get(url)

			rooms = response['rooms']

			if rooms['dorms'].length > 0
				rooms['dorms'].each do |room|
					add_room(room, hostel.id, check_in)
				end
			end

			if rooms['privates'].length > 0
				rooms['privates'].each do |room|
					add_room(room, hostel.id, check_in)
				end
			end 
		end
	end

	def self.add_room(room, provider_id, check_in)
		r = RoomAvailability.new
		r.hw_property_id = provider_id
		r.room_id = room['id']
		r.available_beds = room['minUnitsRemaining']
		r.checkin_date = check_in

		r.save
	end
end
