class AddDescriptToBackhauls < ActiveRecord::Migration
  def change
    add_column :backhauls, :descript, :text
  end
end
