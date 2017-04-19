class CreateBookingPropertyPhotos < ActiveRecord::Migration[5.0]
  def change
    create_table :booking_property_photos do |t|
    	t.integer :booking_property
    	t.string :provider_id
    	t.string :photo_id
    	t.string :url_small
    	t.string :url_medium
    	t.string :url_large
      t.timestamps
    end
  end
end
