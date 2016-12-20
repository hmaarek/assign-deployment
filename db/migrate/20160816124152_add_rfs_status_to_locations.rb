class AddRfsStatusToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :rfs_status, :string
  end
end
