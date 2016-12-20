class Fiberstrand < ActiveRecord::Base
  belongs_to :cable
  
  validates_presence_of :name, :porta, :portb, :cable_id
  
  after_save :set_devport_fiber_id
  
  #run a query to build a list of all availbale ports in the 
  #location of the Point A of the cable...
  #addition (23 June): build only the free ports list
  #adjustment (25 June): porta goes into fiber_out only, and portb goes into fiber_in only
  def list_ports_a
    loca = Cable.find_by_id(cable_id).location_a_id
    
    Devport.where("location_id = " + loca.to_s + " AND (fiber_out_id = 0 )") # OR fiber_out_id = 0)") -(25 June)
  end
  
  def list_ports_b
    locb = Cable.find_by_id(cable_id).location_b_id
    Devport.where("location_id = " + locb.to_s + " AND (fiber_in_id = 0)") # OR fiber_out_id = 0)")
  end
  
  protected
  
  #this sets Devport either fiber_in_id or fiber_out_id
  #it will first look which one is zero, and sets that to the current fiber id
  #if both are not zeros, it will yeild to fiber_in_id to set (had to pick one)
  def set_devport_fiber_id
    #binding.pry
    #get the devport assigned
    dvprt = Devport.find_by_id(porta)  #cannot be nill...user chose already a valid port
    
    #june-25 adjustments:
    dvprt.fiber_out_id = id #(porta)
    dvprt.save
    dvprt = Devport.find_by_id(portb)
    dvprt.fiber_in_id = id  #(portb)
    dvprt.save
    
    #this is commented-out by adjustment in June-25. Porta->fiber_out, Portb->fiber_in
        #if dvprt.fiber_in_id == 0
        #  dvprt.fiber_in_id = id
        #elsif dvprt.fiber_out_id == 0
        #  dvprt.fiber_out_id = id
        #else
        #  dvprt.fiber_in_id = id #overwrite it then
        #end
        
        #save that one devport
        dvprt.save
          
        #now do the same for portb...
        #dvprt = Devport.find_by_id(portb)  #cannot be nill...use chose already a valid port
        #if dvprt.fiber_in_id == 0
        #  dvprt.fiber_in_id = id
        #elsif dvprt.fiber_out_id == 0
        #  dvprt.fiber_out_id = id
        #else
        #  dvprt.fiber_in_id = id #overwrite it then
        #end
        
        #save that one too...
        #dvprt.save

    
  end
  

  #----------------------------------------------
  def self.import_fiber(fibername, portA, portB, cableID, connID)
    #binding.pry
    #+ " AND porta = '" + portA.to_s + "'" + " AND portb = '" + portB.to_s + "'"
    fbr = Fiberstrand.where("cable_id = '" + cableID.to_s + "' AND name LIKE '" + fibername.to_s + "'" ).first
    if fbr.nil?
      fbr = create ([name: fibername.to_s, cable_id: cableID, porta: portA, portb: portB, connection_id: connID]).first
      fbrID = fbr.id
      
      #if fbr.nil? || fbrID <= 0
      #  binding.pry 
      #end
      
    else

    #24Aug2016: you cannot have dublicate fiberstrands...and you cannot overwrite...
    # return an error so that backhaul/feeder will be deleted.
    # If user needs to update old data in a feeder/backhauil, he has to delete it first
      fbr.name = fibername.to_s
      fbr.cable_id =  cableID
      fbr.porta= portA
      fbr.portb= portB
      fbr.connection_id = connID
      fbr.save
      
      #fbrID =0
      fbrID = fbr.id
      
      #binding.pry
      
    end
    
    fbrID  #return rack id
    
  end
  #-----------------------------------------------

 def self.list_connection_fibers (connID) 
    
    flist = Fiberstrand.where ("connection_id = " + connID.to_s)
    
  end
 
 def self.list_cable_fibers (cableID) 
    
    flist = Fiberstrand.where ("cable_id = " + cableID.to_s)
    
  end
  
end
