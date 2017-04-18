class CreateBookingPropertyPhotos < ActiveRecord::Migration[5.0]
  def change
    create_table :booking_property_photos do |t|
    	t.references :booking_property
    	t.string :provider_id
    	t.string :photo_id
      t.timestamps
    end
  end
end
