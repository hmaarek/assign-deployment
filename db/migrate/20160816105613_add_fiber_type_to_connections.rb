class AddFiberTypeToConnections < ActiveRecord::Migration
  def change
    add_column :connections, :fiber_type, :string
  end
end
