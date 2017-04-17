class CreateRoomAvailabilities < ActiveRecord::Migration[5.0]
  def change
    create_table :room_availabilities do |t|
    	t.references :hw_property
    	t.integer :room_id
    	t.integer :available_beds
    	t.datetime :checkin_date
      t.timestamps
    end
  end
end
