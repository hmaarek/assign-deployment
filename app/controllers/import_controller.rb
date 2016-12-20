$import_file_row_number = "---"
$import_file_row_data = "---"

require 'sinatra'
require 'pusher'

# Post endpoint that creates account with realtime magic
#post '/import-data-form' do
#  binding.pry
#  name = params[:name]
#  uid = params[:uid]
#  pusher_channel = "signup_process_#{uid}"
#  fake_background_job(name, pusher_channel)
#end



class ImportController < ApplicationController
  
  def import
    
    #binding.pry

  end #end import

  
  def impproces
    
  ## required keys for Pusher. you can find them in your dashboard at https://app.pusherapp.com/
  #Pusher.app_id = ENV['PUSHER_APP_ID']
  #Pusher.key = ENV['PUSHER_APP_KEY']
  #Pusher.secret = ENV['PUSHER_APP_SECRET']

  #binding.pry
    pusher_channel = "signup_process_#{current_user.id}"  # create a channel for real time update of the view, using pusher
    
    #pusher_client = Pusher::Client.new(app_id: "238741", key: "7f6f786b11c7ec5320a9", secret: "824a9eb680eed6345708", encrypted: true)
    
    createdConnectionIDs=[]
    createdConnections=0

    createdPortIDs=[]
    createdPorts=0

    
    #hash containing text decsribing the type of the backhaul
    bhType = {0 => "Backhaul", 1 => "Feeder"}
    
    #binding.pry
  
    @file = params[:file]
    @msg = "<br>"
  begin        

    if (@file.nil?)
      @msg="<h3><font color=\"FF0000\"> No File Selected, please try again </font></h3>" #<br><p><a  onclick=\"history.back();\">Back</a></p>"
      raise "File not selected"
      #binding.pry
    end #else
    
    

      spreadsheet = Roo::Spreadsheet.open(@file)
      header = spreadsheet.row(1) 
      
      
      if (params[:patch_connect]) == "1"
        
        @msg="<h3><font color=\"FF0000\">Feature Not Implemented Yet </font></h3>"
        raise "Feature Not Implemented Yet, Please uncheck the box 'Import Patch Connect File'"
        import_patch_ports(spreadsheet, header)
        
        return
      end


      #1.Get:
      #   Seg Count (no of segments in that bakhaul)
      #   backhaul name
      #   Ring Name
      #   RFS Status (Yes/No)
      row = Hash[[header, spreadsheet.row(2)].transpose]
      
      backhaulName = readRowData(row["Name"])  #name of the backhaul/feeder
      backhaulType = readRowData(row["Type"])  #type: B: Backhaul, F: Feeder
      ringName = readRowData(row["Ring Name"])  #Ring name in case of Backhaul only
      #binding.pry
      backhaulType="B" if (backhaulType.nil? || backhaulType.empty?)
      
      bkType = 0  #type is Backhaul      
      bkType = 1 if (backhaulType.casecmp("F")==0)
      
      rfsStatus = readRowData(row["RFS Status"])

      #august 3: reamove seg count, and work only on empty cable name as the end of the segment
      #segCount = row["Seg Count"]
  
  #binding.pry
      #validate header:
      ##August 3 no segCount...
      #raise MyError.new("[Seg Count] cannot be empty or Zero") if segCount.nil? || segCount==0
      raise StandardError.new("[Backhaul/Feeder] name cannot be empty") if (backhaulName.nil? || backhaulName.empty?)
      raise StandardError.new("[RFS Stauts] Error (cannot be empty, or other than Yes or No") if (rfsStatus.nil? || rfsStatus.empty? || (rfsStatus.casecmp("Yes")!=0 && rfsStatus.casecmp("No")!=0))
      
      binding.pry
      raise StandardError.new("Feeders cannot be part of a Ring, Ring name has to be empty for Feeders") if (bkType==1 && (!ringName.nil? && !ringName.empty?))

      #create the required ring, if ringName is not empy
      ringID=0
      if (!ringName.nil?)
        
        ringDesc = readRowData(row["Ring Description"])
        
        ringID = Ring.import_ring(ringName, ringDesc)
        
      end

      bkhID = Backhaul.import_backhual(backhaulName, rfsStatus, bkType, "imported from: " + @file.original_filename, ringID)
      raise StandardError.new("#{bhType[bkType]}: [#{backhaulName}] Already Exists...cannot overwrite! Please delete if first.") if bkhID ==0
      @backhaulID = bkhID
      
      
      #@msg = @msg + "<h3> Bakhul ID: " + bkhID.to_s + "</h3><br>"
      
      header = spreadsheet.row(4) 
      
      freeConn = 0  #index of free (Dark) connections
      increment=0
      
      #start this loop, from here to the end of the file
      (5..spreadsheet.last_row).each do |i| 
        
      $import_file_row_number = i.to_s
      
      importASeg=true
      
      #if (i==9)
      #  binding.pry
      #end
      
      #row_info = "<b> Processing Row no.: " + i.to_s + "</b>"
      #render inline: row_info.html_safe
      
      #1. Get connection Data. Format should be:
        #  Customer Name: text
        #  Connection ID: text
        #  Connection Status: (Live, Dark, Reserved)
        #  Connection Utilization: text
        #  Request Category: (Prov, FRR)
        #  Request ID: zoho req ID (text)
        row = Hash[[header, spreadsheet.row(i)].transpose]
        
        $import_file_row_data = row.to_s
        
        #binding.pry
        customerName = readRowData(row["Customer Name"])      #.to_s.strip
        connectionName = readRowData(row["Connection ID"])      #.to_s.strip
        connectionStatus = readRowData(row["Connection Status"])     #.to_s.strip
        
        #binding.pry if (connectionStatus.casecmp("Reserved")==0)
        
        connectionStatus = "Live" if (!connectionStatus.nil? && connectionStatus.casecmp("Active")==0)
        
        connectionUtil = readRowData(row ["Connection Utilization"])     #.to_s.strip
        reqCateg = readRowData(row ["Request Category"])     #.to_s.strip
        reqID = readRowData(row["Request ID"])     #.to_s.strip
    
      
    
        #binding.pry    
        if customerName == "END_OF_FILE" 
          break
        end
        
      #2.Create that connection...if it is not already created...
        # if it was created before, update it (see the model for that)
        #if connection name is empty, create a connection a free connection:
        #   Status = Dark  (as per original design, dark means free)
        #   customerName = "N/A"
        #   request_category: "N/A"
        #   request_id: 0
        #   description: Free Connection ready to be assigned to a customer
        
        
        #this is old news now....obsoleted
        #if (connectionName.nil?)
        #  connectionName = "Not Assigned"
        #  conn_id=0
        #end
        
        # no connection, create a free one (Dark)
        #binding.pry
        if (customerName.empty? || customerName.nil? || connectionName.nil? || connectionName.empty?)
          
          raise StandardError.new("Error in row: "+ i.to_s + " - Reserved Conecction and no Customer/Connection Name given") if (connectionStatus.casecmp("Reserved")==0)
          
          customerName = "N/A"
          freeConn = freeConn + 1
          connectionName = "Free Connection " + freeConn.to_s
          connectionStatus = "Dark"
          connectionUtil = "Free Connection ready to be assigned to a customer"
          reqCateg = "N/A"
          reqID = "N/A"
          cust_id = 0

        else
          #binding.pry
          #raise MyError.new("Error in row: "+ i.to_s + "\nCustomer Name has to be empty for [Dark] connections") if connectionStatus.casecmp("Dark")==0
          raise StandardError.new("Error in row: "+ i.to_s + " - Customer Name has to be empty for [Dark] connections") if connectionStatus.casecmp("Dark")==0
          cust_id = Customer.import_customer(customerName)
        end
        
            #if this is a Feeder, read the fiber type
            rfsBuildingStatus="N/A"
            rfsDate = ("1/1/1900").to_date
            noOfHomePassed=0
            noOfHomeConnected=0
            fiberType="N/A" 
            if (bkType==1)  #type is feeder
              fiberType = readRowData(row["Fiber Type"])   # type of that connection
              rfsBuildingStatus = readRowData(row["RFS Building Status"])  #status for the last given Location in that row (connection)
              rfsBuildingStatus = "YES" if (rfsBuildingStatus.casecmp("RFS")==0)
              
              fiberType="N/A" if (fiberType.nil? || fiberType.empty?)
              rfsBuildingStatus = "N/A" if (rfsBuildingStatus.nil? || rfsBuildingStatus.empty?)
              
              if (fiberType.casecmp("GPON")!=0 && fiberType.casecmp("P2P")!=0 && fiberType.casecmp("N/A")!=0)  #cannot be other thing
                raise StandardError.new("Error in row: "+ i.to_s + " - Fiber Type has to be either Empty(not implemented), P2P, or GPON")
              end
              
              
              rfsDateStr = readRowData(row["RFS Date"])
              rfsDateStr = "1/1/1900" if (rfsDateStr.nil? || rfsDateStr.empty?)
              rfsDate = rfsDateStr.to_date

              #noOfHomePassedStr = readRowData(row["No. of Home Passed"])
              noOfHomePassed = 0 #noOfHomePassedStr.to_i
              
              #noOfHomeConnectedStr = readRowData(row["No. of Home Connected"])
              noOfHomeConnected = 0  #noOfHomeConnectedStr.to_i
            end


#need to allow the file of creating duplicate connections (same name)...jus tcheck if the ports/fibers are different
        if importASeg
          conn_id = Connection.import_conn(connectionName, cust_id, connectionStatus, connectionUtil, reqCateg, reqID, bkhID, fiberType)
          #store the conn_id to be able to delete all connections later when/if we fail later in the file
          createdConnectionIDs[createdConnections]=conn_id
          createdConnections +=1
        end
        #@msg = @msg + "cust ID: " + cust_id.to_s + " , connection ID: " + conn_id.to_s + "<br>"

        segCount = 1000  #enfinity
      #3.Start reading segments...repeat by segCount
        for seg in 1..segCount
        #binding.pry
          raise StandardError.new("Max no. of segments reached(999), segment= "+ seg.to_s + " Please check with sysadmin or split file into less segments, less than 999") if seg>=999 
        
        #24Aug2016: only import segA if importASeg is true
        
        #3.1 read location data, create location if neede
          locationName = readRowData(row["Location Name "+ seg.to_s])
          locationType = readRowData(row["Location Type " + seg.to_s])
          locationAddress = readRowData(row["Location Address "+ seg.to_s])
          
          raise StandardError.new("[Location Name "+ seg.to_s + "] cannot be empty") if (locationName.nil? || locationName.empty?)
          raise StandardError.new("[Location type "+ seg.to_s + "] cannot be empty") if (locationType.nil? || locationType.empty?)
    
          #make sure we have that location, or create it
          locID = Location.import_location(locationName, locationType, locationAddress, rfsBuildingStatus, rfsDate, noOfHomePassed, noOfHomeConnected)
          #binding.pry
          #@msg = @msg + "<br> --- COID:"  + locID.to_s
          
          
        #3.2 read rack data, create rack if needed
        #3.2.1 (17 Aug2016): if device  type is NOT ODF, then rack type is 0, and should take the same name as the TD
        #3.3 read device data, create device if needed
          devName = readRowData(row["TD ID "+ seg.to_s])
          devType = readRowData(row["TD Type "+ seg.to_s])
          devType="ODF" if (devType.nil? || devType.empty?)  #default to ODF if ommitted
          raise StandardError.new("[TD ID" + seg.to_s + "] cannot be empty") if (devName.nil? || devName.empty?)

          rackName = readRowData(row["Rack ID "+seg.to_s])
          #binding.pry
          if importASeg
            if devType.casecmp("ODF")==0
              raise StandardError.new("[Rack ID "+ seg.to_s + "] cannot be empty") if (rackName.nil? || rackName.empty?)
              rackID = NetRack.import_rack(rackName,1, locID)   #rack type = 1 (ODF)
            else  #for non-ODF devices, rack name is the same as the device name
              rackID = NetRack.import_rack(devName,0, locID)  #rack type = 0 (non-ODF): used devName not rack name
            end
  
            #create the device...
            #binding.pry
            devID = Device.import_device(devName, rackID, devType)
          end
          #@msg = @msg + "<br> --- DecID:"  + devID.to_s
          
        #3.4 read port data, create port if not found
          #binding.pry
          prtName = readRowData(row["Port ID "+seg.to_s])
          raise StandardError.new("Port ID cannot be empty for Location Name (" + locationName + "), And Device ID: " + devName ) if (prtName.nil? || prtName.empty?)
          
          if importASeg
            prtID = Devport.import_port(prtName.to_s, devID, locID)
            raise StandardError.new("Cannot dublicate ports #{prtName.to_s} on device: #{devName.to_s}" ) if prtID ==0          
          if !createdPortIDs.include?(prtID)
            createdPortIDs[createdPorts] = prtID
            createdPorts +=1
          end
          end
          #@msg = @msg + "<br> --- prtID:"  + prtID.to_s
          
          
        #.....cables and fibers.....................................
        #3.5 read Cable data, create cable if not found
          cableName = readRowData(row["Cable Name "+ seg.to_s])
          cableSizeS = readRowData(row["Cable Size "+ seg.to_s])
          #binding.pry
          cableSize= cableSizeS.to_i

         #24Aug raise StandardError.new("[Cable Name " + seg.to_s + "] cannot be empty") if (cableName.nil? || cableName.empty?)
         break if (cableName.nil? || cableName.empty?)

          
          # Here, we will need both location-A (current one) and location-B (from the next seg)
          nextSeg = seg+1
          locAID = locID
          
          locationBType = readRowData(row["Location Type " + nextSeg.to_s])
          locationBAddress = readRowData(row["Location Address "+ nextSeg.to_s])
          
          locationBAddress="N/A" if (locationBAddress.nil? || locationBAddress.empty?)
          raise StandardError.new("[Location type "+ nextSeg.to_s + "] (locaiton B) cannot be empty") if (locationBType.nil? || locationBType.empty?)

          locBName = readRowData(row ["Location Name " + nextSeg.to_s])  #next segment
          raise StandardError.new("[Location Name " + nextSeg.to_s + "] location B cannot be empty") if (locBName.nil? || locBName.empty?)

          #create location B if needed
          locBID = Location.import_location(locBName, locationBType, locationBAddress, rfsBuildingStatus, rfsDate, noOfHomePassed, noOfHomeConnected )
          #binding.pry
          #@msg = @msg + "<br> --- LocBID:"  + locBID.to_s

          
          cableID = Cable.import_cable(cableName, cableSize, locAID, locBID, bkhID)
          
          #@msg = @msg + "<br> --- cableID:"  + cableID.to_s
          
        #3.6 read fiberstrand, and create if needed
          fiberName = readRowData(row["Fiberstrand ID "+ seg.to_s])
          break if (fiberName.nil? || fiberName.empty?)  #no fiber id provided, end loop  ###Aug 3##next if fiberName.nil? #no fiber id provided, ignore assignment for this port
      
          #read the PortB details...may need to create it too :(
          #this means we need to read: location, rack, device and then port data
#-------------------------------------------------------------------------------------------------------------------          
          #B.1 read location data, create location if needed
          #location B data is already read, (locBID)
          
          
          
          
          #B.2 read rack data, create rack if needed
          #B.3 read device data, create device if needed
          devBName = readRowData(row["TD ID "+ nextSeg.to_s])
          devBType = readRowData(row["TD Type "+ nextSeg.to_s])
          devBType="ODF" if (devBType.nil? || devBType.empty?)   #default to ODF if ommitted
          raise StandardError.new("[TD B ID" + nextSeg.to_s + "] cannot be empty") if (devBName.nil? || devBName.empty?)

          rackBName = readRowData(row["Rack ID "+nextSeg.to_s])


          if devBType.casecmp("ODF")==0
            raise StandardError.new("[Rack B ID "+ nextSeg.to_s + "] cannot be empty") if (rackBName.nil? || rackBName.empty?)
            rackBID = NetRack.import_rack(rackBName, 1, locBID)     #rack type = 1 (ODF)
          else  #for non-ODF devices, rack name is the same as the device name
            rackBID = NetRack.import_rack(devBName, 0, locBID)    #rack type = 0 (non-ODF): used devName not rack name
          end

          #create the device...
          #binding.pry
          devBID = Device.import_device(devBName, rackBID, devBType)
          
          #@msg = @msg + "<br> --- DevBID:"  + devID.to_s
          
          #B.4 read port data, create port if not found...finally
          prtBName = readRowData(row["Port ID "+nextSeg.to_s])
          raise StandardError.new("Port B ID cannot be empty for Location Name (" + locBName + "), And Device ID: " + devBName ) if (prtBName.nil? || prtBName.empty?)                    

          prtBID = Devport.import_port(prtBName.to_s, devBID, locBID)
          raise StandardError.new("Cannot dublicate ports #{prtBName.to_s} on device: #{devBName.to_s} devBID: #{devBID}, locBID: #{locBID}" ) if prtBID ==0
          
          if !createdPortIDs.include?(prtBID)
            createdPortIDs[createdPorts] = prtBID
            createdPorts +=1
          end
          #@msg = @msg + "<br> --- prtBID:"  + prtBID.to_s
#-------------------------------------------------------------------------------------------------------------------          
          
          #now we have all that it takes to create the fiber link!!
          fbrID = Fiberstrand.import_fiber(fiberName, prtID, prtBID, cableID, conn_id)
          raise StandardError.new("(seg = #{nextSeg}) Cannot dublicate fiberB: #{fiberName} on deviceA: #{devName} and deviceB: #{devBName}///, porta =#{prtID}, portb=#{prtBID}, cableID = #{cableID}, connId = #{conn_id} ." ) if fbrID ==0
          #@msg = @msg + "<br> --- fiberID:"  + fbrID.to_s
          
          #24Aug2016: swap values
          prtID = prtBID
          prtName = prtBName
          devID = devBID
          devName = devBName
          rackID = rackBID
          rackName = rackBName
          
          
          #Aug 3## now, if no fiber for next segment, break the segment loop...this marks end of connection
          fiberName = readRowData(row["Fiberstrand ID "+ nextSeg.to_s])
          break if (fiberName.nil? || fiberName.empty?)   #no fiber id provided for the next segment, end loop 
          importASeg = false
        end #end for loop (segment loop)
  
        #update progress bar...
        increment = ((i*100)/(spreadsheet.last_row-5))
        Pusher.trigger(pusher_channel, 'update', {message: "Importing Row #{i.to_s} of #{spreadsheet.last_row.to_s}", progress: increment}) #((i*100)/(spreadsheet.last_row-5)) })
        #pusher_client.trigger(pusher_channel, 'update', {message: "Importing Row #{i.to_s} of #{spreadsheet.last_row.to_s}", progress: increment})
        
      end  #end file loop

      @msg = "File imported Succesffuly..."
  

    rescue => e
      #binding.pry
      #  e was e.thing
      @backhaulID =0
      @msg="<h3><font color=\"FF0000\">ERROR:<br>" + e.to_s + "</font></h3><hr>Import File Row: "+$import_file_row_number + "<br>Row Info: " + $import_file_row_data
      
      @msg = @msg + "<hr>Error Location information: " + $@[0..5].to_s	 #<br><p><a  onclick=\"history.back();\">Back</a></p>"
      
      #delete all connections created...24Aug2016. This sovles the issue of 
      # having fake connections strangled in the DB when there was a file import failure
      
      if defined? bkhID
        #inding.pry
        Backhaul.find_by_id(bkhID).destroy if (!bkhID.nil? && bkhID> 0)
      end
      
      if defined? createdConnections
        createdConnectionIDs.each do |connID|
          conn = Connection.find_by_id(connID)
          flist = Fiberstrand.where("connection_id = " + conn.id.to_s)
          flist.each do |fiber|
            fiber.destroy if (!fiber.nil? && fiber.id >0)
          end
          conn.destroy if (!conn.nil? && conn.id >0)
        end
        
        #delete created ports
        createdPortIDs.each do |prtID|
          prt = Devport.find_by_id(prtID)
          prt.destroy if (!prt.nil? && prt.id >0)
        end

        
      end
  
      if (defined? i)
        @msg = @msg + "<br> row no.: " +  i.to_s + "<br><br>"
      end
      puts "Exception Handeled"
      #@msg = @msg + "<br><p><a href=\"#\" onclick=\"history.back();\">Back</a></p>"
        
  end  #end begin

  
  @msg

  end #impproces end
  

private

#function to make sure data has been stripped of spaces...
  def readRowData(row)
    str = row.to_s
    str.strip! if !str.nil?
    str
  end
  

#importing the other type of file....patch ports connect map
def import_patch_ports (spreadsheet, header)
  
  
  return
  
  row = Hash[[header, spreadsheet.row(2)].transpose]
  binding.pry
  
end


end   #---- end controller class--------------------------------



 
