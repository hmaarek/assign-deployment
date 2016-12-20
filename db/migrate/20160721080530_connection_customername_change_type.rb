class ConnectionCustomernameChangeType < ActiveRecord::Migration
  def change
    change_column(:connections, :customer_id, :integer)
  end
end
