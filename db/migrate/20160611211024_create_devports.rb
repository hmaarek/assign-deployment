class CreateDevports < ActiveRecord::Migration
  def change
    create_table :devports do |t|
      t.string :name
      t.integer :portno
      t.integer :fiber_id
      t.references :devices, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
