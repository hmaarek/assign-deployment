class CreateBackhauls < ActiveRecord::Migration
  def change
    create_table :backhauls do |t|
      t.string :name
      t.string :rfs_status

      t.timestamps null: false
    end
  end
end
