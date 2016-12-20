class ChangeContractExpierDateType < ActiveRecord::Migration
  def change
    change_column(:contracts, :expiring_date, :date)
  end
end
