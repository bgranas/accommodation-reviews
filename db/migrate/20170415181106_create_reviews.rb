class CreateReviews < ActiveRecord::Migration[5.0]
  def change
    create_table :reviews do |t|
    	t.references :hw_property
    	t.integer :review_id
    	t.string :username
    	t.string :nationality
    	t.string :gender
    	t.string :age
    	t.integer :num_reviews
    	t.text :text
    	t.datetime :date
    	t.decimal :overall_rating
    	t.decimal :value
    	t.decimal :security
    	t.decimal :location
    	t.decimal :facilities
    	t.decimal :staff
    	t.decimal :atmosphere
    	t.decimal :cleanliness
      t.timestamps
    end
  end
end
