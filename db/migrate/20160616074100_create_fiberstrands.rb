class CreateFiberstrands < ActiveRecord::Migration
  def change
    create_table :fiberstrands do |t|
      t.string :name
      t.integer :porta
      t.integer :portb
      t.references :cable, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
