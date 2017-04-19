class BookingProperty < ApplicationRecord
	
	validates_uniqueness_of :provider_id
	#has_many :booking_property_photos
	#has_many :booking_property_facilities
	#has_many :booking_property_reviews

  def self.get_ratings
    a = Mechanize.new
    a.user_agent_alias = 'Windows Chrome'

    hotels = BookingProperty.where(review_count: nil).order('id ASC')

    hotels.each do |hotel|
      puts 'STARTING: ' + hotel.id.to_s
      page = a.get(hotel.hotel_url)

      begin
        review_score = page.search('.average.js--hp-scorecard-scoreval')[0].text.squish if page.search('.average.js--hp-scorecard-scoreval')[0]
        if review_score
          review_number = page.search('.score_from_number_of_reviews .count')[0].text.squish
          cleanliness = page.search('#review_list_score_breakdown .review_score_value')[0].text if page.search('#review_list_score_breakdown .review_score_value')[0]
          comfort = page.search('#review_list_score_breakdown .review_score_value')[1].text if page.search('#review_list_score_breakdown .review_score_value')[1]
          location = page.search('#review_list_score_breakdown .review_score_value')[2].text if page.search('#review_list_score_breakdown .review_score_value')[2]
          facilities = page.search('#review_list_score_breakdown .review_score_value')[3].text if page.search('#review_list_score_breakdown .review_score_value')[3]
          staff = page.search('#review_list_score_breakdown .review_score_value')[4].text if page.search('#review_list_score_breakdown .review_score_value')[4]
          value_for_money = page.search('#review_list_score_breakdown .review_score_value')[5].text if page.search('#review_list_score_breakdown .review_score_value')[5]
          free_wifi = page.search('#review_list_score_breakdown .review_score_value')[6].text if page.search('#review_list_score_breakdown .review_score_value')[6]

          hotel.update_attributes overall_rating: review_score, review_count: review_number, cleanliness: cleanliness,
                                         comfort: comfort, location: location, facilities: facilities, staff: staff,
                                         value_for_money: value_for_money, free_wifi: free_wifi
          sleep(1)
        else
          hotel.update_attributes(overall_rating: nil)
        end
      rescue StandardError => e
        puts 'Skipping: ' + hotel.id.to_s + " due to #{e.inspect} on #{e.backtrace.inspect[0]}"
      end

    end

    # end
  end

	def self.get_all_booking_properties
		
		offset = 0
		continue = true

    client_id = 'triphappy'
    client_secret = 'triphappyapi'

    authorization_header = Base64.strict_encode64("#{client_id}:#{client_secret}")
		
		while continue
			
			url = "https://distribution-xml.booking.com/json/bookings.getHotels?offset=#{offset}&rows=60&languagecode=en"
			response = HTTParty.get(url, headers: {'Authorization' => "Basic #{authorization_header}"})
			puts response[0]
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
	    	t.pagename = hotel['pagename']

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

	def self.get_booking_descriptions
    client_id = 'triphappy'
    client_secret = 'triphappyapi'

    authorization_header = Base64.strict_encode64("#{client_id}:#{client_secret}")
		
		
		offset = 0
		continue = true

		while continue
			url = "https://distribution-xml.booking.com/json/bookings.getHotelDescriptionTranslations?descriptiontype_ids=1,6&languagecodes=en&offset=#{offset}&rows=100"
																												
			response = HTTParty.get(url, headers: {'Authorization' => "Basic #{authorization_header}"})
			puts response
			response.each do |desc|
				hotel = BookingProperty.find_by(provider_id: desc['hotel_id'])
				hotel.description = desc['description']
				hotel.save
			end
			if response.length == 1000
				offset += 1000
			else
				continue = false
			end

		end
	end

end
