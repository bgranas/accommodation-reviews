class HwProperty < ApplicationRecord
	has_many :hw_facilities
	has_many :reviews
	has_many :room_types
	has_many :room_availabilities
	validates_uniqueness_of :provider_id

	
	def self.get_subratings
		a = Mechanize.new
		a.user_agent_alias = 'Windows Chrome'

		hostels = HwProperty.where.not('overall_rating > ?', 0.0).order('id ASC').limit(6)
		hostels.each do |hostel|
			url = "http://www.hostelworld.com/hosteldetails.php/#{hostel.provider_id}/reviews"
			p = a.get(url)

			if p.search('.ratingword').text != 'No RatingNo Rating'

				hostel.value_rating = p.search('.ratingbreakdownlist li')[0]&.search('.ratingpercent')&.text.to_d
				hostel.security_rating = p.search('.ratingbreakdownlist li')[1]&.search('.ratingpercent')&.text.to_d
				hostel.location_rating = p.search('.ratingbreakdownlist li')[2]&.search('.ratingpercent')&.text.to_d
				hostel.staff_rating = p.search('.ratingbreakdownlist li')[3]&.search('.ratingpercent')&.text.to_d
				hostel.atmosphere_rating = p.search('.ratingbreakdownlist li')[4]&.search('.ratingpercent')&.text.to_d
				hostel.cleanliness_rating = p.search('.ratingbreakdownlist li')[5]&.search('.ratingpercent')&.text.to_d
				hostel.facilities_rating = p.search('.ratingbreakdownlist li')[6]&.search('.ratingpercent')&.text.to_d

				hostel.save
			end
			sleep(1)
		end

	end
end
