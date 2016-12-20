class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string :name
      t.string :address
      t.string :type

      t.timestamps null: false
    end
  end
end
