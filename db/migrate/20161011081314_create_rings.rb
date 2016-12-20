class CreateRings < ActiveRecord::Migration
  def change
    create_table :rings do |t|
      t.string :name
      t.text :description

      t.timestamps null: false
    end
  end
end
