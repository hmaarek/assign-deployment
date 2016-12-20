class Fixcableidname2 < ActiveRecord::Migration
  def change
    rename_index :fiberstrands, 'Cable_id', 'cable_id'
  end
end
