class CreateBookingProperties < ActiveRecord::Migration[5.0]
  def change
    create_table :booking_properties do |t|

      t.timestamps
    end
  end
end
