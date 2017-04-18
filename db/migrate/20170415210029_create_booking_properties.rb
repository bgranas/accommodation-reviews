class CreateBookingProperties < ActiveRecord::Migration[5.0]
  def change
    create_table :booking_properties do |t|
    	t.integer :provider_id
    	t.string :name
    	t.decimal :overall_rating
    	t.integer :review_count
      t.decimal :value_rating
      t.decimal :location_rating
      t.decimal :staff_rating
      t.decimal :comfort_rating
      t.decimal :cleanliness_rating
      t.decimal :facilities_rating
    	t.string :address
    	t.string :city
    	t.string :provider_city_id
    	t.string :country_code
    	t.integer :property_type
    	t.text :description
    	t.string :base_currency
    	t.decimal :lat
    	t.decimal :lng
    	t.decimal :star_rating
    	t.datetime :creation_date
    	t.integer :max_people_per_booking
    	t.integer :min_rate
    	t.integer :max_rate
    	t.integer :nr_rooms
    	t.string :url
      t.timestamps
    end
  end
end
