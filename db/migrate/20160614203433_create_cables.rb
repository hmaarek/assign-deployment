class CreateCables < ActiveRecord::Migration
  def change
    create_table :cables do |t|
      t.string :name
      t.integer :size

      t.timestamps null: false
    end
  end
end
