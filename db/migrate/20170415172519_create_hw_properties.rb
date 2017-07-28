class CreateHwProperties < ActiveRecord::Migration[5.0]
  def change
    create_table :hw_properties do |t|
    	t.integer :provider_id
    	t.string :name
    	t.decimal :overall_rating
    	t.integer :review_count
      t.decimal :value_rating
      t.decimal :security_rating
      t.decimal :location_rating
      t.decimal :staff_rating
      t.decimal :atmosphere_rating
      t.decimal :cleanliness_rating
      t.decimal :facilities_rating
    	t.string :address
    	t.string :phone
    	t.string :city
    	t.integer :provider_city_id
    	t.string :country
    	t.integer :provider_country_id
    	t.string :property_type
    	t.text :description
    	t.string :base_currency
    	t.decimal :lat
    	t.decimal :lng
    	t.string :directions
    	t.decimal :star_rating
    	t.integer :deposit_percent
    	t.datetime :creation_date
    	t.integer :max_people_per_booking
    	t.integer :min_dorm_price
    	t.integer :min_private_price
      t.timestamps
    end
  end
end
