class AddRfsDateToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :rfs_date, :date
  end
end
