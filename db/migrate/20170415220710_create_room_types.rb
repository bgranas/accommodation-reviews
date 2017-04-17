class CreateRoomTypes < ActiveRecord::Migration[5.0]
  def change
    create_table :room_types do |t|
    	t.references :hw_property
    	t.integer :room_id
    	t.integer :num_beds
    	t.string :room_category
    	t.string :room_subtype
    	t.decimal :price

      t.timestamps
    end
  end
end
