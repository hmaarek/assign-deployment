class ChangeContractSignedDateType < ActiveRecord::Migration
  def change
    change_column(:contracts, :signed_date, :date)
  end
end
