class AddBackhaulidToConnection < ActiveRecord::Migration
  def change
    add_column :connections, :backhaul_id, :integer
  end
end
