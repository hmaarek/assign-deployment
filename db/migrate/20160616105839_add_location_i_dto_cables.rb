class AddLocationIDtoCables < ActiveRecord::Migration
  def change
    add_column :cables, :location_id, :integer
  end
end
