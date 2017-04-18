class CreateBookingPropertyFacilities < ActiveRecord::Migration[5.0]
  def change
    create_table :booking_property_facilities do |t|

      t.timestamps
    end
  end
end
