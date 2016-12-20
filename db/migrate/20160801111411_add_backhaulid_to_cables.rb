class AddBackhaulidToCables < ActiveRecord::Migration
  def change
    add_column :cables, :backhaul_id, :integer
  end
end
