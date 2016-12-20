class Ring < ActiveRecord::Base
    validates_presence_of :name
    has_many :backhauls
    
    
    
    
  #----------------------------------------------
  def self.import_ring(ringName, desc)
    #binding.pry
    ring = Ring.where("name LIKE '" + ringName + "'").first
    if ring.nil?
      ring= create ([name: ringName, description: desc]).first
      newRingID = ring.id
    else # if ring was found, return the existing ring ID
        newRingID =ring.id  #cannot override an existing Ring
    end
    
    newRingID  #return Ring id
    
  end
  #-----------------------------------------------

    
end
