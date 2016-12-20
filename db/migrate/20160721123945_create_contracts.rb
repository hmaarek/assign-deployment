class CreateContracts < ActiveRecord::Migration
  def change
    create_table :contracts do |t|
      t.string :contract_name
      t.integer :customer_id
      t.datetime :signed_date
      t.datetime :expiring_date
      t.text :description

      t.timestamps null: false
    end
  end
end
