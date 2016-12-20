class Backhaul < ActiveRecord::Base
    
    
    
  #----------------------------------------------
  def self.import_backhual(bhName, rStatus, bkType, desc, ringID)
    #binding.pry
    bkh = Backhaul.where("name LIKE '" + bhName + "'").first
    if bkh.nil?
      bkh= create ([name: bhName, rfs_status: rStatus, bkh_type: bkType,descript: desc, ring_id: ringID]).first
      newID = bkh.id
    else # modify backhaul data according to what is found in the imported file
    
    #24Aug2016...refuse the override of an existing backhaul. User has to delete it first
    # return zero id to delcare failure of creation
        #bkh.name = bhName
        #bkh.rfs_status = rStatus
        #bkh.descript = desc
        #bkh.bkh_type = bkType
        #bkh.save
        
        newID =0  #cannot override an existing backhaul/feeder
    end
    
    newID  #return bakhaul id
    
  end
  #-----------------------------------------------



  def calculateCapacity
    
    connections = Connection.where("backhaul_id =" + id.to_s)
    darkConns=0
    liveConns=0
    resrvConns=0
    otherConns=0
    #minFiberSum=0
    totalCapacity=0
    
    connections.each do |conn|
      
      ustr = conn.status.upcase
      
      case ustr
        when "DARK"
          darkConns += 1
          
        when "LIVE"
          liveConns +=1 
          
        when "RESERVED"
          resrvConns +=1
          
        else
          otherConns +=1
      end  #end case
    
      #last building fiber sum (for Feeders)
      #lastFiberSize = conn.??????
    
    end #end connections loop
    
  #this is wrong...need to be displayeed per circuit...not per backhaul
  #the total capacity is cable size of the cable in first segment (first port)
    #fiberSum = darkConns + liveConns + resrvConns + otherConns
    #the capacity of that cable/backhaul, is the smallest fibersum of any segment in it
    # minFiberSum = fiberSum if (minFiberSum==0 || minFiberSum > fiberSum)
    #totalCapacity...
   # binding.pry
    connection = Connection.where("backhaul_id =" + id.to_s).first
          #binding.pry
    firstPortID = connection.get_first_port #need to get a connection in that BH
    
    #binding.pry if Devport.find_by_id(firstPortID).nil?
    
    fiberOutID = Devport.find_by_id(firstPortID).fiber_out_id
    if fiberOutID.nil?
      capacity = Hash["TotalFiber" => "--", "ActiveFiber" => "Port Not Found...DB Error! ", "ReservedFiber" => "-- ", "AllocatedFiber" => "-- ", "PercentAllocation" => " --", "AvailableFiber" => "-- ", "PercentAvailableFiber" => " --", "Flag" => "-- "]
      return capacity
    end

    fiber = Fiberstrand.find_by_id(fiberOutID)
    if fiber.nil?
      capacity = Hash["TotalFiber" => "--", "ActiveFiber" => "Fiber Not Found...DB Error! ", "ReservedFiber" => "-- ", "AllocatedFiber" => "-- ", "PercentAllocation" => " --", "AvailableFiber" => "-- ", "PercentAvailableFiber" => " --", "Flag" => "-- "]
      return capacity
    end
    
    cable = Cable.find_by_id(fiber.cable_id)
    if cable.nil?
      capacity = Hash["TotalFiber" => "--", "ActiveFiber" => "Cable Not Found...DB Error! ", "ReservedFiber" => "-- ", "AllocatedFiber" => "-- ", "PercentAllocation" => " --", "AvailableFiber" => "-- ", "PercentAvailableFiber" => " --", "Flag" => "-- "]
      return capacity
    end
    totalCapacity = cable.size #!!!
    
    #now, prepare all capacity figures, stuff them in a hash, send the hash to the called...
    #1. Total implemented fiber = minFiberSum
    #2. Active fiber = liveConns
    #3. Reserved fiber = reservConns
    #4. Allocated Fiber:
    allocatedFiber = liveConns + resrvConns
    
    #5. % of fiber allocated:
    allocationRatio = (allocatedFiber*100) / totalCapacity # this was: minFiberSum
    
    #6. Available fiber
    availableFiber = totalCapacity - allocatedFiber  #this was: minFiberSum - allocatedFiber
    
    #7. % of available fiber
    availableFiberRatio = (availableFiber * 100) / totalCapacity  #this was: minFiberSum
    
    #8. flagState:
    flagState = false
    flagState= true if (allocationRatio >= 80) 
    
    #prepare the HASH array (sytnax: H = Hash["a" => 100, "b" => 200])
    #capacity = Hash["TotalFiber" => minFiberSum, "ActiveFiber" => liveConns, "ReservedFiber" => resrvConns, "AllocatedFiber" => allocatedFiber, "PercentAllocation" => allocationRatio, "AvailableFiber" => availableFiber, "PercentAvailableFiber" => availableFiberRatio, "Flag" => flagState]
    capacity = Hash["TotalFiber" => totalCapacity, "ActiveFiber" => liveConns, "ReservedFiber" => resrvConns, "AllocatedFiber" => allocatedFiber, "PercentAllocation" => allocationRatio, "AvailableFiber" => availableFiber, "PercentAvailableFiber" => availableFiberRatio, "Flag" => flagState]
    
    #return vaqlue:
    capacity
    
  end  #end function
    
  
  
  def self.getTotalFeeders
    
    totalFdrs = 0
    
    backhauls = Backhaul.where("bkh_type = 1")  #feeders
    totalFdrs = backhauls.count
    
    totalFdrs
  end


  def self.getTotalBakhauls
    
    totalbkhs = 0
    
    backhauls = Backhaul.where("bkh_type = 0")  #feeders
    totalbkhs = backhauls.count
    
    totalbkhs
  end


end
