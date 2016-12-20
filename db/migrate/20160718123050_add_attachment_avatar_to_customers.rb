class AddAttachmentAvatarToCustomers < ActiveRecord::Migration
  def self.up
    change_table :customers do |t|
      t.attachment :avatar
    end
  end

  def self.down
    remove_attachment :customers, :avatar
  end
end
