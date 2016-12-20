class AddLocationIdToDevport < ActiveRecord::Migration
  def change
    add_column :devports, :location_id, :integer
  end
end
