class Cable < ActiveRecord::Base
    has_many :fiberstrands  #, dependent: :destroy
    belongs_to :location
    
    validates_presence_of :name, :size , :location_a_id,:location_b_id






  #----------------------------------------------
  def self.import_cable(cablename, cablesize, locA, locB, bkhID)
    #binding.pry
    cable = Cable.where("location_a_id = '" + locA.to_s  + "' AND location_b_id = '" + locB.to_s + "' AND name LIKE '" + cablename + "'").first
    if cable.nil?
      cable = create ([name: cablename, location_a_id: locA, location_b_id: locB, size: cablesize, backhaul_id: bkhID]).first
    else
      cable.name= cablename
      cable.location_a_id= locA
      cable.location_b_id= locB
      cable.size= cablesize
      cable.backhaul_id= bkhID
      
      cable.save
    end
    
    cable.id  #return rack id
    
  end
  #-----------------------------------------------
    
    
   def self.list_backhaul_cables (bkhID) 
    
    cbllist = Cable.where ("backhaul_id = " + bkhID.to_s)
    
  end

 
 
end
