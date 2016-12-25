class ConnectionDescpTypeChange < ActiveRecord::Migration
  def change
  
    change_column :connections, :description, :text
    
  end
end
