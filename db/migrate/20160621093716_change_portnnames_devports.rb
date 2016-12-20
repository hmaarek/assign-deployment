class ChangePortnnamesDevports < ActiveRecord::Migration
  def change
    rename_column :devports, 'portno', 'fiber_in_id'
    rename_column :devports, 'fiber_id', 'fiber_out_id'
  end
end
