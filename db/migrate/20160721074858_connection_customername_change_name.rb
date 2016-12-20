class ConnectionCustomernameChangeName < ActiveRecord::Migration
  def change
    rename_column :connections, :customer_name, :customer_id
  end
end
