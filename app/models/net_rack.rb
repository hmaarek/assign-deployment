class NetRack < ActiveRecord::Base
  belongs_to :location
  has_many :devices, dependent: :destroy
  
  validates_presence_of :name, :size
  
  
  
  #----------------------------------------------
  def self.import_rack(rackname, rackType, coID)
    
    nr = NetRack.where("location_id = '" + coID.to_s + "' AND name LIKE '" + rackname + "'").first
    if nr.nil?
      nr = create ([location_id: coID, name: rackname, size: 100]).first
      
    else
      nr.name= rackname
      nr.location_id= coID
      nr.rack_type = rackType
      #will not change size
      
      nr.save
    end
    
    nr.id  #return rack id
    
  end
  #-----------------------------------------------




end

