class AddRingIdToBackhauls < ActiveRecord::Migration
  def change
    add_column :backhauls, :ring_id, :integer
  end
end
