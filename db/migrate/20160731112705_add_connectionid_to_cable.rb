class AddConnectionidToCable < ActiveRecord::Migration
  def change
    add_column :cables, :connection_id, :integer
  end
end
