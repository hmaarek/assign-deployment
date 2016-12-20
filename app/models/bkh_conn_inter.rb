class BkhConnInter < ActiveRecord::Base
    validates_presence_of :bkh_id, :conn_id
    has_many :backhauls
    has_many:connections
    validates_uniqueness_of :conn_id, scope: :bkh_id



def self.link_conn_to_bkh (connID, bkhID)
    
    rec = BkhConnInter.new
    
    rec.bkh_id = bkhID
    rec.conn_id = connID
    
    rec.save

end

end
