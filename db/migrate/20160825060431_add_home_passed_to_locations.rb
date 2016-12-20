class AddHomePassedToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :home_passed, :integer
  end
end
