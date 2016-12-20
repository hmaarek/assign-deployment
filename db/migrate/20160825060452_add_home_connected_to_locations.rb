class AddHomeConnectedToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :home_connected, :integer
  end
end
