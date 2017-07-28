class AddRoomTypeToAvailability < ActiveRecord::Migration[5.0]
  def change
  	add_column :room_availabilities, :room_type, :string
  end
end
