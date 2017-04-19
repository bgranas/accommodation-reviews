class CreateBookingPropertyFacilities < ActiveRecord::Migration[5.0]
  def change
    create_table :booking_property_facilities do |t|
    	t.integer :provider_id
    	t.integer :hotelfacilitytype_id
    	t.string :name
      t.timestamps
    end
  end
end
