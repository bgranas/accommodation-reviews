class CreateBookingPropertyReviews < ActiveRecord::Migration[5.0]
  def change
    create_table :booking_property_reviews do |t|
    	t.string :username
    	t.string :country
    	t.integer :num_reviews
    	t.decimal :overall_rating
    	t.string :title
    	t.text :pos_text
    	t.text :neg_text
    	t.boolean :owner_responded
    	t.datetime :date
      t.timestamps
    end
  end
end
