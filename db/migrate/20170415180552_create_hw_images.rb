class CreateHwImages < ActiveRecord::Migration[5.0]
  def change
    create_table :hw_images do |t|
    	t.references :hw_property
    	t.string :image_size
    	t.string :url
    	t.integer :height
    	t.integer :width
      t.timestamps	
    end
  end
end
