class Devport < ActiveRecord::Base
  belongs_to :device
  
  validates_presence_of :name
 
 
     
  #  def reset_fiber_in(id)
  #    dev = Devport.find_by_id(id)
  #    dev.fiber_in_id = 0
  #  end

  #  def reset_fiber_out(id)
  #    dev = Devport.find_by_id(id)
  #    dev.fiber_out_id = 0
  #  end




  #----------------------------------------------
  def self.import_port(portname, devID, locID)
    #binding.pry
    prt = Devport.where("device_id = '" + devID.to_s + "' AND name LIKE '" + portname + "'").first
    if prt.nil?
      prt = create ([name: portname, device_id: devID, fiber_in_id: 0, fiber_out_id: 0, location_id: locID]).first
      prtID = prt.id
    else
      
    #24Aug2016: you cannot have dublicate ports...and you cannot overwrite...
    # return an error so that backhaul/feeder will be deleted.
    # If user needs to update old data in a feeder/backhauil, he has to delete it first

      #prt.name= portname
      #prt.device_id= devID
      
      #fiber in and out will be set correctly when we import fiber data
      #prt.fiber_in_id= 0  
      #prt.fiber_out_id= 0
      
      #prt.location_id= locID
      
      #prt.save
      prtID =0
    end
    
    prtID  #return port id
    
  end
  #-----------------------------------------------



end
