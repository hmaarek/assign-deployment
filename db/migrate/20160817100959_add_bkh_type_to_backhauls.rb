class AddBkhTypeToBackhauls < ActiveRecord::Migration
  def change
    add_column :backhauls, :bkh_type, :integer
  end
end
