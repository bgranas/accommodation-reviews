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
end
