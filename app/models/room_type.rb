class RoomType < ApplicationRecord
	belongs_to :hw_property

	include HTTParty
	def self.get_room_types(provider_id)
		hostels = HwProperty.where(provider_city_id: provider_id).order('id ASC')
		check_in = "2017-09-06"
		check_out = "2017-09-07"
		hostels.each do |hostel|

			url = "http://www.hostelworld.com/microsite/get-availability?dateFrom=#{check_in}&dateTo=#{check_out}&propNum=#{hostel.provider_id}&number_of_guests=1"
			response = HTTParty.get(url)

			dorms = response['rooms']['dorms'] if response['rooms']
			privates = response['rooms']['privates'] if response['privates']


			if dorms
				dorms.each do |dorm|
					add_room(dorm, "dorm", hostel.id)
				end
			end

			if privates
				privates.each do |priv|
					add_room(priv, "private", hostel.id)
				end
			end

		end
	end

	def self.add_room(room, category, provider_id)
		r = RoomType.new
		r.hw_property_id = provider_id
		r.room_id = room['id']
		if room['minUnitsRemaining'] > room['beds'].to_d || category == "private"
			r.num_beds = room['minUnitsRemaining']
		else
			r.num_beds = room['beds'].to_d
		end
		r.room_category = category
		r.room_subtype = "#{room['numofbeds']} #{room['roomtypename']}"
		r.price = room['averagePrice'][0]

		r.save

		puts r.room_id
		puts r.room_subtype
	end
end
