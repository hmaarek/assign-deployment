class CreateCustomers < ActiveRecord::Migration
  def change
    create_table :customers do |t|
      t.string :name
      t.string :contact_name
      t.string :contact_title
      t.string :contact_phone
      t.text :notes

      t.timestamps null: false
    end
  end
end
