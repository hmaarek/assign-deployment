class RemoveconnectionidFromcables < ActiveRecord::Migration
  def change
    remove_column :cables, :connection_id, :integer
  end
end
