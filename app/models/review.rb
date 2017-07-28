class Review < ApplicationRecord
	self.table_name = "hw_reviews"
	belongs_to :hw_property

	validates_uniqueness_of :review_id

	require 'csv'

	def self.pull_reviews_by_city(city_id)

		props = HwProperty.where(provider_city_id: city_id).order('id ASC')

		props.each do |prop|
			review_scraper(prop)
		end

	end

	def self.pull_reviews_by_prop(id)
		prop = HwProperty.find(id)
		review_scraper(prop)
	end


	def self.review_scraper(prop, prov_url)
		a = Mechanize.new
		a.user_agent_alias = 'Windows Chrome'

		crashed_on = []
		cont = true
		i = 1
		r_id = 0 #variable to check if stuck in infinite loop

		while cont
			begin
				prop_formatted = prop.name.gsub('&amp;', '-and-').gsub('  ',' ').gsub(/[^0-9A-Za-z -]/, '').gsub(' - ','-').gsub(' ','-').gsub('--','-')
				city_formatted = prop.city.gsub('&amp;', '-and-').gsub('  ',' ').gsub(/[^0-9A-Za-z -]/, '').gsub(' - ','-').gsub(' ','-').gsub('--','-')
				url = prov_url + "/#{prop_formatted}/#{city_formatted}/#{prop.provider_id}/reviews?lang=all&sortOrder=newest&showOlderReviews=1&page=#{i}#reviewFilters"
				puts "******PAGE: " + url.to_s
				p = a.get(url)

				#check if stuck in infinite loop, if yes break loop
				if i == 1
					r_id = p.search('.reviewlisting')[0].search('.reviewtext')[0]['id'].partition('w').last.to_i
				end
				if i == 2
					first_id = p.search('.reviewlisting')[0].search('.reviewtext')[0]['id'].partition('w').last.to_i
					if first_id == r_id
						crashed_on << prop.id
						break
					end
				end

				reviews = p.search('.reviewlisting')
				reviews.each do |review|

					r = Review.new
					
					r.hw_property_id = prop.id
					r.review_id = review.search('.reviewtext')[0]['id'].partition('w').last.to_i
					r.username = review.search('.reviewername').text.squish
					r.nationality = review.search('.reviewerdetails').text.split(', ')[0]&.squish
					r.gender = review.search('.reviewerdetails').text.split(', ')[1]&.squish
					r.age = review.search('.reviewerdetails').text.split(', ')[2]&.squish
					r.num_reviews = review.search('.reviewernumber').text.split(' ')[0].squish
					r.text = review.search('.reviewtext p').text
					d = DateTime.parse(review.search('.reviewdate').text.squish)
					r.date = d.strftime('%d/%b/%Y')
					r.overall_rating = review.search('.textrating').text.to_i

					list = review.search('.ratinglist')
					r.value = list[0].search('li span')[0].text
					r.security = list[0].search('li span')[1].text
					r.location = list[0].search('li span')[2].text
					r.facilities = list[0].search('li span')[3].text
					r.staff = list[1].search('li span')[0].text
					r.atmosphere = list[1].search('li span')[1].text
					r.cleanliness = list[1].search('li span')[2].text

					r.save

				end

				if p.search('.pagination-next i.fa-angle-double-right').length > 0
					i = i + 1
				else
					cont = false
				end

				sleep(1)
			rescue StandardError => e
				crashed_on << prop.id
				cont = false
			end
		end
		puts 'CRASHED ON: ' + crashed_on.to_s
	end

	def self.median(array)
	  sorted = array.sort
	  len = sorted.length
	  (sorted[(len - 1) / 2] + sorted[len / 2]) / 2.0
	end

	def self.city_30day_neg(provider_city_id)
		total_reviews = Review.joins(:hw_property).where('hw_properties.provider_city_id' =>  provider_city_id).where('date > ?', '2017-04-04 00:00:00').count
		neg_reviews = Review.joins(:hw_property).where('hw_properties.provider_city_id' =>  provider_city_id).where('date > ?', '2017-04-04 00:00:00').where('hw_reviews.overall_rating < ?', 7.0)
		age = Review.joins(:hw_property).where('hw_properties.provider_city_id' =>  provider_city_id).where('date > ?', '2017-04-04 00:00:00').where('hw_reviews.overall_rating < ?', 7.0).group('hw_reviews.age').count
		nationality = Review.joins(:hw_property).where('hw_properties.provider_city_id' =>  provider_city_id).where('date > ?', '2017-04-04 00:00:00').where('hw_reviews.overall_rating < ?', 7.0).group('hw_reviews.nationality').count

		puts 'TOTAL REVIWS IN CITY DURING TIME FRAME: ' + total_reviews.to_s
		puts "TOTAL NEG REVIEWS: " + neg_reviews.count.to_s + " ACROSS " + neg_reviews.pluck(:hw_property_id).uniq.count.to_s + " PROPERTIES"
		puts Hash[age.sort_by{|k, v| v}.reverse]
		puts Hash[nationality.sort_by{|k, v| v}.reverse]
		neg_reviews.each do |prop|
			puts prop.hw_property_id.to_s + " | " + prop.text.to_s
		end
	end

	def self.city_seasonality(provider_city_id)

		reviews = Review.joins(:hw_property).where('hw_properties.provider_city_id' =>  provider_city_id)
		jan = reviews.where('date > ?', '2016-01-01 00:00:00').where('date < ?', '2016-1-31 00:00:00').count
		feb = reviews.where('date > ?', '2016-02-01 00:00:00').where('date < ?', '2016-2-29 00:00:00').count
		mar = reviews.where('date > ?', '2016-03-01 00:00:00').where('date < ?', '2016-3-31 00:00:00').count
		apr = reviews.where('date > ?', '2016-04-01 00:00:00').where('date < ?', '2016-4-30 00:00:00').count
		may = reviews.where('date > ?', '2016-05-01 00:00:00').where('date < ?', '2016-5-31 00:00:00').count
		jun = reviews.where('date > ?', '2016-06-01 00:00:00').where('date < ?', '2016-6-30 00:00:00').count
		jul = reviews.where('date > ?', '2016-07-01 00:00:00').where('date < ?', '2016-7-31 00:00:00').count
		aug = reviews.where('date > ?', '2016-08-01 00:00:00').where('date < ?', '2016-8-31 00:00:00').count
		sep = reviews.where('date > ?', '2016-09-01 00:00:00').where('date < ?', '2016-9-30 00:00:00').count
		oct = reviews.where('date > ?', '2016-10-01 00:00:00').where('date < ?', '2016-10-31 00:00:00').count
		nov = reviews.where('date > ?', '2016-11-01 00:00:00').where('date < ?', '2016-11-30 00:00:00').count
		dec = reviews.where('date > ?', '2016-12-01 00:00:00').where('date < ?', '2016-12-31 00:00:00').count
	
	end

	def self.global_seasonality

		CSV.open("seasonality.csv","w") do |csv|
			Review.joins(:hw_property).group('hw_properties.provider_city_id').pluck(:provider_city_id).uniq.each do |city|
				city_name = HwProperty.where(provider_city_id: city)[0].city
				country = HwProperty.where(provider_city_id: city)[0].country
				reviews = Review.joins(:hw_property).where('hw_properties.provider_city_id' =>  city)
				jan = reviews.where('date > ?', '2016-01-01 00:00:00').where('date < ?', '2016-1-31 00:00:00').count
				feb = reviews.where('date > ?', '2016-02-01 00:00:00').where('date < ?', '2016-2-29 00:00:00').count
				mar = reviews.where('date > ?', '2016-03-01 00:00:00').where('date < ?', '2016-3-31 00:00:00').count
				apr = reviews.where('date > ?', '2016-04-01 00:00:00').where('date < ?', '2016-4-30 00:00:00').count
				may = reviews.where('date > ?', '2016-05-01 00:00:00').where('date < ?', '2016-5-31 00:00:00').count
				jun = reviews.where('date > ?', '2016-06-01 00:00:00').where('date < ?', '2016-6-30 00:00:00').count
				jul = reviews.where('date > ?', '2016-07-01 00:00:00').where('date < ?', '2016-7-31 00:00:00').count
				aug = reviews.where('date > ?', '2016-08-01 00:00:00').where('date < ?', '2016-8-31 00:00:00').count
				sep = reviews.where('date > ?', '2016-09-01 00:00:00').where('date < ?', '2016-9-30 00:00:00').count
				oct = reviews.where('date > ?', '2016-10-01 00:00:00').where('date < ?', '2016-10-31 00:00:00').count
				nov = reviews.where('date > ?', '2016-11-01 00:00:00').where('date < ?', '2016-11-30 00:00:00').count
				dec = reviews.where('date > ?', '2016-12-01 00:00:00').where('date < ?', '2016-12-31 00:00:00').count
				# puts "Jan: " + jan.to_s
				# puts "Feb: " + feb.to_s
				# puts "Mar: " + mar.to_s
				# puts "Apr: " + apr.to_s
				# puts "May: " + may.to_s
				# puts "Jun: " + jun.to_s
				# puts "Jul: " + jul.to_s
				# puts "Aug: " + aug.to_s
				# puts "Sep: " + sep.to_s
				# puts "Oct: " + oct.to_s
				# puts "Nov: " + nov.to_s
				# puts "Dec: " + dec.to_s
			
				csv << [city, city_name, country, jan, feb, mar, apr, may, jun, jul, aug, sep, oct, nov, dec]
			end
		end
	end

end
