
require 'sinatra'
require 'pusher'

## required keys for Pusher. you can find them in your dashboard at https://app.pusherapp.com/
Pusher.app_id = ENV['PUSHER_APP_ID']
Pusher.key = ENV['PUSHER_APP_KEY']
Pusher.secret = ENV['PUSHER_APP_SECRET']

    dEBUG_ME =1

class SearchController < ApplicationController
  
  #get search/search
  def search
    
    #binding.pry
    
    @search_subject = params[:format]
    puts "---> search_controller: search, params= " + params[:format].to_s

  end
  
  
  #post /search/locationsearch
  def loc_searchprocess

    #binding.pry
    #puts ("at search: loc_searchprocess")

    qres = Location.search(params[:q])
    

    num=1
    @message = ""
    @count = qres.count
    qres.each do |loc|
      @message += "<tr>"
      @message += "<td align='left'>" + num.to_s + "</td>"
      @message += "<td align='left'>" + view_context.link_to(loc.name, loc) + "</td>"
      @message += "<td align='left'>" + loc.location_type.to_s + "</td>"
      @message += "</tr>"

      num += 1
    end
  
    #binding.pry
    #redirect_to locations_search_path #(msg: @message)
  end


#----------------------------------------------------------------------------
#post /search/pointtrace


  def pointtrace

    #binding.pry
    @devListA=[]
    @devListB=[]
    @portList=[]
    @connList=[]
    @customerList= []
    @conn_segments=[]
    

    
    pusher_channel = "link_trace_#{current_user.id}"  # create a channel for real time update of the view, using pusher
    
    maxhubs = 100
    
    puts "---> search_controller: cbl_searchprocess, params= " + params.to_s

    #-----testing new idea of 3 screens------31 Oct-------------------------
    
    
    devloc = params[:selected_itm_a][0]
    itemID = params[:selected_itm_a][1, 10].to_i
    
    
    #device list in location A:
    if (devloc=="L") #item a is a location...build a list of 
    
      loc = Location.find(itemID)  
      
      #build a list of devices in that location 
      i=0
      loc.net_racks.each do |nrack|    #get all racks inside that location
        nrack.devices.each do |dev|  #get devs inside each rack
          if !(@devListA.include? dev.id)
            @devListA[i] = dev.id
            i += 1
          end
        end
      end
      
    else #use the give device id to build a list of only one device
      @devListA [0] = Device.find(itemID)
    end
    
    #now, the same for point B
    devloc = params[:selected_itm_b][0]
    itemID = params[:selected_itm_b][1, 10].to_i
    
    
    #device list in location B:
    if (devloc=="L") #item a is a location...build a list of 
    
      loc = Location.find(itemID)  
      
      #build a list of devices in that location 
      i=0
      loc.net_racks.each do |nrack|    #get all racks inside that location
        nrack.devices.each do |dev|  #get devs inside each rack
          if !(@devListB.include? dev.id)
            @devListB[i] = dev.id
            i += 1
          end
        end
      end
      
    else #use the give device id to build a list of only one device
      @devListB [0] = Device.find(itemID)
    end
    
    
    #here we have a full list of all required devices...
    #binding.pry
    

    #-MAIN Loop----------------------------------------------------------------------
    @count = 1


  #do this for each devince in @devListA
        
        
    indx = 0  #main indx in the main ports list (@portList)

  
    barLength = @devListA.count
    barcountr = 0
    Pusher.trigger(pusher_channel, 'reset', {message: "--"})
    
    @devListA.each do |devAID|

      #now, start search from all ports in deva, and stop wehn you find devb, or 100 hubs
      
      devports = Device.find_by_id(devAID).devports
      
      #do this for all ports in devA

    #main_loop
      devports.each do |cport|    #cport: current port
      
        itrt = true
        cntr=0

        prt = cport
        while itrt
          break if prt.nil?
    
          
      #-- break if fid-out is zero, or we reach devB, or we exceed 100 hubs...termination point -->
      #-- if we reversed the trace starting from the end point and moving down to the start point-->
      
          fid = prt.fiber_out_id
      
          break if fid==0
      
    #  <!-- start from fiber_out and continue using fiber_out then loop (unless reversed, use fiber-in) -->
      
          fiber = Fiberstrand.find_by_id(fid)
          break if fiber.nil?
    
    #      <!-- get the next port, from portb of the current cable -->
    
          prt = Devport.find_by_id(fiber.portb)
          

          #if we found destination (devB), count this port in the list, and break the while loop now
          #here the break out condition is that the "device in prt" is contained in point B device list
          #if (!prt.nil? && prt.device_id == devbID)
          if (!prt.nil? &&  (@devListB.include? prt.device_id)) # prt.device_id == devbID)
            @portList[indx] = cport.id
            indx += 1
              #binding.pry
            break #break from the port loop
          end
    
    #      <!-- upto 100 hubs only...after that something went wrong for sure -->
          cntr += 1
          break if cntr>maxhubs
          

          
        end  #end while
  
      #binding.pry
  
    end   #end each do
    
    
    #update progress bar...
    increment = ((barcountr*100)/(barLength))
    Pusher.trigger(pusher_channel, 'update', {message: "(1/2) Buiding List of Ports of devices at location A, Processing Device: #{barcountr.to_s} of #{barLength}", progress: increment})
    barcountr += 1

    
  end #main @devListA loop
  
  #binding.pry
    
    #now, at this point we have a list of ports that carry fibers going to the direction of devB
    #...using this list, build the list of connections too
    
    #binding.pry
 
    indx = 0
    barLength = @portList.count
    @portList.each do |prtID|
      
      prt = Devport.find_by_id(prtID)
      fbrO = prt.fiber_out_id
      
      connID = Fiberstrand.find_by_id(fbrO).connection_id
      if connID==0     #exelcude those fibers with no connection attached to them
        @connList[indx] = 0
        @customerList[indx] = 0
      else
        @connList[indx] = Fiberstrand.find_by_id(fbrO).connection_id
        @customerList[indx] = Connection.find_by_id(@connList[indx]).customer_id
      end
      
      @conn_segments[indx] = "X--"
      
     # binding.pry
      
      itrt = true
      cntr=0
      while itrt
        break if prt.nil?
        
        fid = prt.fiber_out_id
        #store the hub
        @conn_segments[indx] += Location.find(prt.location_id).name
        break if fid==0

        @conn_segments[indx] += "------" 
        #binding.pry if dEBUG_ME == 1

        fiber = Fiberstrand.find_by_id(fid)
        break if fiber.nil?

        prt = Devport.find_by_id(fiber.portb)
        
        cntr += 1
        break if cntr>maxhubs

      end
      
      @conn_segments[indx] += "--X"
      indx +=1

        #update progress bar...
        increment = ((indx*100)/(barLength))
        Pusher.trigger(pusher_channel, 'update', {message: "(2/2) Processing links, Link: #{indx.to_s} of #{barLength}", progress: increment})

      
    end
    

    
    @count = indx-1
    
#    @srcDev = Device.find_by_id(devaID)
#    @dstDev = Device.find_by_id(devbID)
#    @srcLocation = Location.find_by_id(@srcDev)
#    @dstLocation = Location.find_by_id(@dstDev)


    #binding.pry

  end
#------------------------------------------------------------------------

  #post /search/cablesearch
  def cbl_searchprocess

    qres = Cable.where("name LIKE ?", "%" + params[:q] + "%")

    num=1
    @message = ""
    @count = qres.count
    qres.each do |cbl|

      bkhname = "--"
      bkh = Backhaul.find_by_id(cbl.backhaul_id)
      bkhname = bkh.name if (!bkh.nil? && bkh.id>0)
      
      loca = Location.find_by_id(cbl.location_a_id)
      locb = Location.find_by_id(cbl.location_b_id)

      @message += "<tr>"
      @message += "<td align='left'>" + num.to_s + "</td>"
      @message += "<td align='left'>" + view_context.link_to(cbl.name, cbl) + "</td>"
      @message += "<td align='left'>" + cbl.size.to_s + "</td>"
      @message += "<td align='left'>" + view_context.link_to(loca.name.to_s, loca)  + "</td>"
      @message += "<td align='left'>" + view_context.link_to(locb.name.to_s, locb) + "</td>"
      @message += "<td align='left'>" + view_context.link_to(bkhname.to_s, bkh) + "</td>"
      @message += "</tr>"

      num += 1
    end



  end


#---------Cable Trace---------------------------------------------------------
  #post /search/cabletrace
  def cbl_traceprocess
   
   #binding.pry
   
  puts "---> search_controller: cbl_traceprocess, params[:qa]= " + params[:qa] + "--, params[:qb]= " + params[:qb]
   
    #-----testing new idea of 3 screens------31 Oct-------------------------
    
    @devListA={}
    @locListA={}
    
    @devListB={}
    @locListB={}



    @message1 ="This is the restuls for screen 1"
    @qA = params[:qa].upcase
    @qB = params[:qb].upcase
    
    exact_match_a = params[:exact_match_a]
    exact_match_b = params[:exact_match_b]
    
    @qA.strip!  if !@qA.nil?  #trip leading and trailing spaces
    @qB.strip!  if !@qB.nil?  #trip leading and trailing spaces
    
    
    incLocA = 0
    incLocA = 1 if !params[:loc_search_a].nil?
    incDevA = 0
    incDevA = 1 if !params[:dev_search_a].nil?

    incLocB = 0
    incLocB = 1 if !params[:loc_search_b].nil?
    incDevB = 0
    incDevB = 1 if !params[:dev_search_b].nil?

    
    #@searchtypeA = "Dev: " + incDevA.to_s + " - Location: " + incLocA.to_s
    #@searchtypeB = "Dev: " + incDevB.to_s + " - Location: " + incLocB.to_s
    
    #binding.pry
    #build lists for point A
    devicesA=nil
    locsA=nil

    if exact_match_a=="1"
      devicesA = Device.where("name = '" + @qA + "'") if incDevA
      locsA = Location.where("name = '" + @qA+ "'") if incLocA

    else
      devicesA = Device.where("name LIKE ?", "%" + @qA + "%") if incDevA
      locsA = Location.where("name LIKE ?", "%" + @qA + "%") if incLocA
    end

    
    if exact_match_b=="1"
      devicesB = Device.where("name = '" + @qB + "'")  if incDevB
      locsB = Location.where("name = '" + @qB + "'") if incLocB
    else
      devicesB = Device.where("name LIKE ?", "%" + @qB + "%") if incDevB
      locsB = Location.where("name LIKE ?", "%" + @qB + "%") if incLocB
    end

 # binding.pry
    
    i=0
    if (!devicesA.nil?)
      devicesA.each do |dev|
        @devListA[i] = dev.id
        i +=1 
      end
    end

   # binding.pry
    iloc=0
    if (!locsA.nil?)
      locsA.each do |loc|
        if !(@locListA.include? loc.id)
          @locListA[iloc] = loc.id   #store the whole location into a separate array
          iloc +=1
        end
        if (incDevA==1)
          loc.net_racks.each do |nrack|    #get all racks inside that location
            nrack.devices.each do |dev|  #get devs inside each rack
              if !(@devListA.include? dev.id)
                @devListA[i] = dev.id
                i += 1
              end
            end
          end
        end
      end
    end

    
    #binding.pry

    #build lists for point B
#    devicesB=nil
#    devicesB = Device.where("name LIKE ?", "%" + @qB + "%") if incDevB
#    locsB=nil
#    locsB = Location.where("name LIKE ?", "%" + @qB + "%") if incLocB


    i=0
    if (!devicesB.nil?)
      devicesB.each do |dev|
        @devListB[i] = dev.id
        i +=1 
      end
    end

   # binding.pry
    iloc=0
    if (!locsB.nil?)
      locsB.each do |loc|
        if !(@locListB.include? loc.id)
          @locListB[iloc] = loc.id   #store the whole location into a separate array
          iloc +=1
        end
        if incDevB==1
          loc.net_racks.each do |nrack|    #get all racks inside that location
            nrack.devices.each do |dev|  #get devs inside each rack
              if !(@devListB.include? dev.id)
                @devListB[i] = dev.id
                i += 1
              end
            end
          end
        end
      end
    end


  end
#-----------------------------------------------------------------



#get search/connectionsearch
  def conn_searchprocess

    qres = Connection.where("name LIKE ?", "%" + params[:q] + "%")

    num=1
    @message = ""
    bktype = ["B", "F"]
    @count = qres.count
    qres.each do |conn|

      bkh = Backhaul.find_by_id(conn.backhaul_id)
      #bkhname = bkh.name if (!bkh.nil? && bkh.id>0)

      customer = Customer.find_by_id(conn.customer_id)
      #custname = customer.name if (!customer.nil? && customer.id>0)


      firstport = conn.get_first_port
      lastport  = conn.get_last_port
      
      if (!firstport.nil? && firstport >0)
        loca = Location.find_by_id(Devport.find_by_id(firstport).location_id)
      end
      
      if (!lastport.nil? && lastport >0)
        locb = Location.find_by_id(Devport.find_by_id(lastport).location_id)
      end
      
      @message += "<tr>"
      @message += "<td align='left'>" + num.to_s + "</td>"
      @message += "<td align='left'>" + view_context.link_to(conn.name, conn) + "</td>"
      
      color = "Black"
      color = "OrangeRed" if (conn.status.casecmp("Live")==0)
      color = "Blue" if (conn.status.casecmp("Reserved")==0)
      
      @message += "<td align='left'> <font color =" + color +">" + conn.status + "</font>" + "</td>"


      if (!customer.nil?)
        @message += "<td align='left'>" + view_context.link_to(customer.name.to_s, customer)  + "</td>"
      else
        @message += "<td align='left'> -- </td>"
      end


      if (!loca.nil?)
        @message += "<td align='left'>" + view_context.link_to(loca.name.to_s, loca)  + "</td>"
      else
        @message += "<td align='left'> -- </td>"
      end

      if (!locb.nil?)
        @message += "<td align='left'>" + view_context.link_to(locb.name.to_s, locb)  + "</td>"
      else
        @message += "<td align='left'> -- </td>"
      end
      
      #28Nov2016
      #get all backhauls that this connection traverses
      bklist = BkhConnInter.where("conn_id = " + conn.id.to_s)
      
      #binding.pry
      
      if !bklist.empty?
        @message += "<td align='left'>"
        bklist.each do |bk|
          if (!bk.nil?)
            bckh = Backhaul.find(bk.bkh_id)
            @message += view_context.link_to(bckh.name.to_s, bckh)

          else
            @message += " --"
          end
            
          @message +=  " || " if bklist.last != bk
  
        end      
      else #bklist is empty...use the primary bkhid if exists
      
        if (!bkh.nil?)
          @message += "<td align='left'>" + view_context.link_to(bkh.name.to_s, bkh) + "</td>"
        else
          @message += "<td align='left'> -- </td>"
        end
        
      end
      @message += "</td>"

      @message += "</tr>"

      num += 1
    end #end qres search

  end #end conn_searchprocess function


end
