class AddConnectionidToFiberstrands < ActiveRecord::Migration
  def change
    add_column :fiberstrands, :connection_id, :integer
  end
end
