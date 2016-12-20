class AddLocationBIdToCables < ActiveRecord::Migration
  def change
    add_column :cables, :location_b_id, :integer
  end
end
