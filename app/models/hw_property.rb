class HwProperty < ApplicationRecord
	has_many :hw_facilities
	has_many :reviews
	has_many :room_types
	has_many :room_availabilities
	validates_uniqueness_of :provider_id

	
	def self.get_subratings(url)
		a = Mechanize.new
		a.user_agent_alias = 'Windows Chrome'

		hostels = HwProperty.where.not('overall_rating > ?', 0.0).order('id ASC').limit(6)
		hostels.each do |hostel|
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

	def self.city_popularity_growth(start_date='2015-01-01',end_date='2015-12-31')
		
		#cur_year = HwProperty.joins(:reviews).where('hw_reviews.date > ? AND hw_reviews.date < ?', start_date,end_date).group('country').count
		#prev_year = HwProperty.joins(:reviews).where('hw_reviews.date > ? AND hw_reviews.date < ?', '2015-01-01','2016-01-01').group('city').count
		cur_year = HwProperty.all.group('hw_properties.country').group('hw_properties.city').uniq.count
		h_cur = Hash[cur_year.sort_by{|k, v| v}.reverse]
		#p_cur = Hash[prev_year.sort_by{|k, v| v}.reverse[0..10]]
		h_cur.each do |k,v|
			puts "#{k[1]},#{k[0]}"
		end
		#puts p_cur
	end

	def self.city_props(start_date='2004-01-01',end_date='2004-12-31')
		#count = HwProperty.joins(:reviews).where('hw_reviews.date > ? AND hw_reviews.date < ?', start_date,end_date).group('city').group('hw_reviews.hw_property_id').uniq.count
		count = HwProperty.group('city').count
		h_cur = Hash[count.sort_by{|k, v| v}.reverse]
		CSV.open("data.csv","w") do |csv|
			h_cur.each do |k,v|
				#csv << [k,v]
				puts "#{k},#{v}"
			end
		end
	end

	def self.review_nationality
		count = HwProperty.joins(:reviews).group('hw_reviews.nationality').count#average('hw_reviews.overall_rating')
		neg = Hash[count.sort_by{|k, v| v}.reverse]
		CSV.open("data.csv","w") do |csv|	
			neg.each do |k,v|
				csv << [k,v]
			end
		end
	end
end
