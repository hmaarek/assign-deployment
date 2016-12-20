class AddRackTypeToNetRacks < ActiveRecord::Migration
  def change
    add_column :net_racks, :rack_type, :integer
  end
end
