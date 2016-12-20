class RenameLocationidInCable < ActiveRecord::Migration
  def change
    rename_column :cables, :location_id, :location_a_id
  end
end
