class CreateBkhConnInters < ActiveRecord::Migration
  def change
    create_table :bkh_conn_inters do |t|
      t.integer :bkh_id
      t.integer :conn_id

      t.timestamps null: false
    end
  end
end
