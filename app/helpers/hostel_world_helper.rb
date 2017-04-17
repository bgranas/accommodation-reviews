# frozen_string_literal: true

# https://affiliate.xsapi.webresint.com/1.1

module HostelWorldHelper
  include HTTParty
  class HostelWorld
    # request type: propertylocationsearch "To search available hostels within specified city and dates."
    # Valid Call:   https://affiliate.xsapi.webresint.com/1.1/citycountrylist.json?consumer_key=triphappy&consumer_signature=7de435e9e463259b35250e323faada2fabccce1f
    # Valid Call: https://affiliate.xsapi.webresint.com/1.1/propertylocationsearch.json?consumer_key=triphappy&consumer_signature=7de435e9e463259b35250e323faada2fabccce1f&City=Poznan&Country=Poland&DateStart=2016-12-20&NumNights=2&Currency=USD&ShowRoomTypeInfo=1
    # NOTE: IN DEVELOPMENT, NEED TO CALL WITH PROXY, SEE: https://devcenter.heroku.com/articles/fixie#your-static-ip-addresses
    # How to use a proxy with HTTPARTY: http://support.quotaguard.com/support/solutions/articles/5000013940-getting-started-with-the-httparty-gem-quotaguard-static

    # params: country and city are strings, full names
    # => lat, lng of city to find hostels in, used with city and country in case of duplicate names
    # => dates are in ISO 8601 format e.g. 2016-12-20
    # sample call: HostelWorld.search_properties('Bangkok', 'Thailand', 13.7563309, 100.5017651, '2016-12-20', '2016-12-24')
    # return: array of hostelworld property ids (they assigned)
    def self.search_properties(city_raw, country_raw, lat, lng, start_date, end_date, currency='USD')
      # Search Parameters
      key = 'triphappy' # API user
      signature = '7de435e9e463259b35250e323faada2fabccce1f' # our secret with a algorithm to transform it
      search_flag = 2 # 1=all available rooms, 2 = only fully bookable, 64 = total price breakdown
      city = URI.encode(city_raw.parameterize)
      country = URI.encode(country_raw.parameterize)

      # TO ASK: How can I search for availability for 2-7 people
      # group_search = num_guests > 1 ? 1 : 0 #0 is false, 1 is true
      # property_types = 'HOSTEL,HOTEL,GUESTHOUSE,CAMPSITE,APARTMENT' #comma separated

      options = {}
      # need to use FIXIE proxy to hit hostelworld
      fixie_url = 'http://fixie:Wsqf4ylq0ORZILe@velodrome.usefixie.com:80' # for fixing IP in development
      proxy = URI(fixie_url)
      options = {http_proxyaddr: proxy.host, http_proxyport: proxy.port, http_proxyuser: proxy.user, http_proxypass: proxy.password}

      query_url = "https://affiliate.xsapi.webresint.com/1.1/propertylocationsearch.json?consumer_key=#{key}&consumer_signature=#{signature}&City=#{city}&Country=#{country}&latitude=#{lat}&longitude=#{lng}&DateStart=#{start_date}&DateEnd=#{end_date}&Currency=#{currency}&ShowRoomTypeInfo=#{search_flag}"
      response = HTTParty.get(query_url, options)

      debug = false
      if debug
        puts "Status: #{response['api']['status']}"
        puts "Results: #{response['result']['ResultCount']}"
        puts "URL: #{query_url}"
      end

      if response['api']['status'] == 'Success' and response['result']['ResultCount'] > 0
        properties = response['result']['Properties']
        property_ids = [] # UID of HostelWorld property
        properties.each do |p|
          property_ids << 'H' + p['number'] # add an H because we've manually added that for hostels in our DB
        end
        return property_ids
      else
        puts '**************** Error: Failed to Hit HostelWorld ****************'
        puts response
        puts '******************************************************************'
        return false
      end
    end

    # helper method for search_properties, allows users to search using a destination object
    # params: destination is a Destination object from the DB
    # sample call: HostelWorld.search_properties_by_destination(d, '2016-12-20', '2016-12-24')
    def self.search_properties_by_destination(destination, start_date, end_date, currency='USD')
      if destination.name && destination.country && destination.lat && destination.lng
        self.search_properties(destination.name, destination.country, destination.lat, destination.lng, start_date, end_date, currency)
      else
        puts '**************** Error: Failed to Hit HostelWorld ****************'
        puts 'Error: Destination missing either name, country, lat, or lng'
        puts '******************************************************************'
        return false
      end
    end

    #helper method to return list of all properties in HW DB
    #useful for refreshing full list of properties 1x per week
    def self.return_all_hostels 
      key = 'triphappy' # API user
      signature = '7de435e9e463259b35250e323faada2fabccce1f' # our secret with a algorithm to transform it

      options = {}
      # need to use FIXIE proxy to hit hostelworld
      fixie_url = 'http://fixie:Wsqf4ylq0ORZILe@velodrome.usefixie.com:80' # for fixing IP in development
      proxy = URI(fixie_url)
      options = {http_proxyaddr: proxy.host, http_proxyport: proxy.port, http_proxyuser: proxy.user, http_proxypass: proxy.password}

      query_url = "https://affiliate.xsapi.webresint.com/1.1/propertiesinformation.json?consumer_key=#{key}&consumer_signature=#{signature}"
      res = HTTParty.get(query_url, options)

      pages_count = res['result']['PagesCount']
      

      i = 1
      while i <= pages_count
        query_url = "https://affiliate.xsapi.webresint.com/1.1/propertiesinformation.json?consumer_key=#{key}&consumer_signature=#{signature}&PageNumber=#{i}"
        response = HTTParty.get(query_url, options)

        if response['api']['status'] == 'Success' and response['result']['ResultCount'] > 0
          puts "parsing results page #{i} out of #{pages_count}"
          properties = response['result']['Properties']
          properties&.each do |prop|      
            t = HwProperty.new

            t.provider_id = prop['propertyNumber']
            t.name = prop['propertyName']
            t.overall_rating = prop['averageRating']
            t.review_count = prop['numRating']
            t.address = prop['address1']
            t.phone = prop['tel']
            t.city = prop['city']
            t.provider_city_id = prop['CityNO']
            t.country = prop['country']
            t.provider_country_id = prop['CountryNO']
            t.property_type = prop['propertyType']
            t.description = prop['descriptionRaw']
            t.base_currency = prop['currency']
            t.lat = prop['geo']['latitude']
            t.lng = prop['geo']['longitude']
            t.directions = prop['directions']
            t.star_rating = prop['starRating']
            t.deposit_percent = prop['depositPercent']
            t.creation_date = prop['creationdate']
            t.max_people_per_booking = prop['maxPax']

            t.save

            #Saves all property facilities
            facilities = prop['facilities']
            facilities&.each do |fac|
              f = HwFacility.new
              f.hw_property_id = t.id
              f.facility = fac

              f.save
            end
          end
        else
          puts 'Something went wrong or there are no hostels to return'
          return false
        end
        i = i + 1
      end   

    end

  end
end


