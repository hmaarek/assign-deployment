class CreateNetRacks < ActiveRecord::Migration
  def change
    create_table :net_racks do |t|
      t.string :name
      t.integer :size
      t.references :location, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
