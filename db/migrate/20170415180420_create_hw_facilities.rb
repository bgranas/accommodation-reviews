class CreateHwFacilities < ActiveRecord::Migration[5.0]
  def change
    create_table :hw_facilities do |t|
    	t.references :hw_property
    	t.string :facility
      t.timestamps	
    end
  end
end
