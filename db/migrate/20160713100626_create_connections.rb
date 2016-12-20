class CreateConnections < ActiveRecord::Migration
  def change
    create_table :connections do |t|
      t.string :name
      t.string :customer_name
      t.string :status
      t.string :description
      t.string :request_category
      t.string :request_id

      t.timestamps null: false
    end
  end
end
