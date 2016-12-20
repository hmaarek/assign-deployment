class FixDevIdname < ActiveRecord::Migration
  def change
    rename_column :devports, :devices_id, :device_id
  end
end
