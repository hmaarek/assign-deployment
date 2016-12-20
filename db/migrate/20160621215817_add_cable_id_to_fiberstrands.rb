class AddCableIdToFiberstrands < ActiveRecord::Migration
  def change
    add_column :fiberstrands, :location_id, :integer
  end
end
