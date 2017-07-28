class RoomAvailability < ApplicationRecord
	belongs_to :hw_property

	include HTTParty
		#IDs for Santiago, Valparaiso, Edinburgh, Mexico City [22, 53, 267, 1868]
		#provider_id is the HostelWorld city ID - this will check all properties in the city
		#check_in_offset is number of days in future to check availability, 0 is tonight
		def self.get_room_availability(provider_id, check_in_offset)
		hostels = HwProperty.where(provider_city_id: provider_id).order('id ASC')
		d = Date.today
		check_in = (d + check_in_offset).strftime('%Y-%m-%d')
		check_out = (d + check_in_offset + 1).strftime('%Y-%m-%d')
		hostels.each do |hostel|
			url = "http://www.hostelworld.com/microsite/get-availability?dateFrom=#{check_in}&dateTo=#{check_out}&propNum=#{hostel.provider_id}&number_of_guests=1"
			puts url.to_s
			response = HTTParty.get(url)

			dorms = response['rooms']['dorms'] if response['rooms']
			privates = response['rooms']['privates'] if response['privates']


			if dorms
				dorms.each do |dorm|
					add_room(dorm, "dorm", hostel.id, check_in)
				end
			end

			if privates
				privates.each do |priv|
					add_room(priv, "private", hostel.id, check_in)
				end
			end
		end
	end

	def self.add_room(room, room_type, provider_id, check_in)
		r = RoomAvailability.new
		r.hw_property_id = provider_id
		r.room_id = room['id']
		r.room_type = room_type
		r.available_beds = room['minUnitsRemaining']
		r.checkin_date = check_in

		r.save
	end

	def self.city_available_tonight(provider_city_id)
		tonight = RoomAvailability.joins(:hw_property).where('hw_properties.provider_city_id' =>  provider_city_id).where('checkin_date < ?', Date.tomorrow).sum(:available_beds).to_i
		total = RoomType.joins(:hw_property).where('hw_properties.provider_city_id' =>  provider_city_id).sum(:num_beds).to_i
		puts (tonight * 100.0) / (total * 100.0)
	end

	def self.prop_availability(provider_city_id)
		#Lists properties and their number of free beds
		RoomAvailability.joins(:hw_property).where('hw_properties.provider_city_id' =>  267).where('checkin_date < ?', Date.tomorrow).group('room_availabilities.hw_property_id, hw_properties.name').sum(:available_beds)

		#Gets properties by total room count
		RoomType.joins(:hw_property).where('hw_properties.provider_city_id' =>  267).group('room_types.hw_property_id, hw_properties.name').sum(:num_beds)
	end

end
