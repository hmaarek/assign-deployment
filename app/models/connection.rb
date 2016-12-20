class Connection < ActiveRecord::Base
    
  before_save :set_dark_connection    
    
#----------------------------------------------
  def self.import_conn(conn_name, cust_id, conn_stat, conn_util, req_cat, req_id, bkhID, fiberType)
    
#28Nov2016:
#check if this is a live/reserved connection, and there exists a connection 
#  with the same name, in that case, join both connections (don't create)

    conQ=nil
    
    if (conn_stat.casecmp("Live")==0 ||  conn_stat.casecmp("Reserved")==0)
      
      conQ = self.where("name LIKE '" + conn_name +"'").first
    end
      
    if (!conq.nil?)
        
        connection = conQ
        
        if bkhID != conQ.backhaul_id #conn traverses across multi backhauls
        
          connection.backhaul_id = bkhID  #use the imported bakhID of course, but log an entry in the junction table
          
          BkhConnInter.list_backhaul_connections(conQ.id, bkhID)
        
        end
      
    else
      connection = create ([name: conn_name, customer_id: cust_id, status: conn_stat, description: conn_util, request_category:  req_cat, request_id: req_id, backhaul_id: bkhID]).first
    
      connection.name = conn_name
      connection.customer_id = cust_id
      connection.status = conn_stat
      connection.description = conn_util
      connection.request_category = req_cat
      connection.request_id = req_id
      connection.backhaul_id = bkhID
      connection.fiber_type = fiberType

      connection.save
      
    end

    connection.id
  end
  #-----------------------------------------------

    
    
  def self.list_backhaul_connections (bkhID) 
    
    clist = Connection.where ("backhaul_id = " + bkhID.to_s)
    
  end
  
  
  #this function searches for the port with fiber_in_id=0, considering this to 
  #  be the first port in a connection trace
  def get_first_port
    flist = Fiberstrand.where("connection_id = " + self.id.to_s)
  
    fportid=0
   # binding.pry
    flist.each do |fiber|
      fport = Devport.find_by_id(fiber.porta)
      fportid=fport.id
      break if (fport.fiber_in_id==0)
      fportid=0
    end
    
    fportid
    
  end
    

  #this function searches for the port with fiber_out_id=0, considering this to 
  #  be the last port in a connection trace...so to get the destination
  def get_last_port
    flist = Fiberstrand.where("connection_id = " + self.id.to_s)
  #binding.pry
    fportid=0
   # binding.pry
    flist.each do |fiber|
      fport = Devport.find_by_id(fiber.portb)
      fportid=fport.id
      break if (fport.fiber_out_id==0)
      fportid=0
    end
    
    fportid
    
  end


  def self.getConnLive
    
    cons = Connection.all
    liveCon = 0
    cons.each do |con|
      liveCon +=1 if con.status.casecmp("Live")==0
    end
    
    liveCon
  end


  def self.getConnRes
    
    cons = Connection.all
    resCon = 0
    cons.each do |con|
      resCon +=1 if con.status.casecmp("Reserved")==0
    end
    
    resCon

  end

  
  protected
  def set_dark_connection
    #binding.pry
    if self.status.casecmp("Dark")==0
      self.customer_id = 0
    end
    
  end
    
end
