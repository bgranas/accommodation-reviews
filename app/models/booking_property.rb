class BookingProperty < ApplicationRecord
	
	validates_uniqueness_of :provider_id

  def self.get_ratings
    a = Mechanize.new
    a.user_agent_alias = 'Windows Chrome'

    hotels = BookingProperty.all.order('id ASC')

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
      # total_done = total_done + 1
      # break if total_done == 250
    end

    # end
  end

end
