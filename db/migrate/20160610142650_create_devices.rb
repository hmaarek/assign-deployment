class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.string :name
      t.string :type
      t.references :net_rack, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
