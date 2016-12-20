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




  #post /search/cablesearch
  def cbl_searchprocess
    
    binding.pry
    
    puts "---> search_controller: cbl_searchprocess, params= " + params.to_s

    #-----testing new idea of 3 screens------31 Oct-------------------------
    
    @count = 1
    @message ="This is the restuls for screen 2, search results"
    


    return
    
    #-----------------------------------------------------------------------


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
    @qA = params[:qa]
    @qB = params[:qb]
    
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

  binding.pry
    
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

      
    #binding.pry
    
    return
    
    #-----------------------------------------------------------------------
 
    @portList= {}
    @connList= {}
    @customerList = {}
    
    dev_a_list={} #all devices found in point A of the search
    dev_b_list={} #all devices found in point B of the search
    
    devaID = params[:device][:devA].to_i
    devbID = params[:device][:devB].to_i
    
    qa = params[:qa]
    qb = params[:qb]
    
    locaID = params[:location][:locA].to_i
    locbID = params[:location][:locB].to_i
    
    searchTypeA = params[:a_search_type]    #=="dev": seach in devices, =='loc': seach in locations
    searchTypeB = params[:b_search_type]
    


binding.pry   


#approach:
  #1. Build a list of devices in point A (this could be one device if point A is a device)
  #2. Build a list of devices in point B (this could be one device if point B is a device)
  #3. loop on all point A deives (nesting main_loop below)
  #4. check if each device in point A belong to the group of devices in B (in main_loop)...
  #5. if so, add this specific "port" in the list of ports @portList

  #device A
  #build a list of devices in point A
    if (!qa.nil? &&  !qa.empty?)  #this takes presedence than devA
    
      if searchTypeA == "dev"
      
        deviceA = Device.where("name LIKE ?", "%" + qa + "%").first
        
        if deviceA.nil?
          @count =0
          @errorMessage = "Could not find Device: [ " + qa.to_s + " ]"
          
          return
        end
        
        #here...we are ok to use the result as a valid location
        devaID = deviceA.id
        
        #our list at point continas only on device
        dev_a_list[0] = deviceA.id
      end
    
      if searchTypeA == "loc"
        #build a list of devices in point A (all that belong to that location )
        locA = Location.where("name LIKE ?", "%" + qa + "%").first
        if locA.nil?
          @count =0
          @errorMessage = "Could not find Location: [ " + qa.to_s + " ]"
          return
        end
      
      
      else  #q is empty...use the drop box result
        
        locA = devaID
        
        
      end #end of edit box not nil
      
      
      
#----------------------------
        #get all deivces in that locaiton
        
        indx=0
        
        locA.net_racks.each do |nrack|    #get all racks inside that location
          
          nrak.devices.each do |dev|  #get devs inside each rack
            dev_a_list[indx] = dev
            indx += 1
          end
          
        end
#-------------------------
    
    end #end of dev A list
    
      

  #device B
    if (!params[:qb].nil? &&  !params[:qb].empty?)  #this takes presedence than devB
    
      deviceB = Device.where("name LIKE ?", "%" + params[:qb] + "%").first
      
      if deviceB.nil?
        @count =0
        @errorMessage = "Could not find: [ " + params[:qb].to_s + " ]"
        
        return
      end
      
      #here...we are ok to use the result as a valid location
      devbID = deviceB.id
    
    end
    
    #binding.pry
    
    #now, start search from all ports in deva, and stop wehn you find devb, or 100 hubs
    
    devports = Device.find_by_id(devaID).devports
    
    #do this for all ports in devA
    indx = 0
#main_loop
    devports.each do |cport|    #cport: current port
    
      itrt = true
      cntr=0
      maxhubs = 100
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
        if (!prt.nil? && prt.device_id == devbID)
          @portList[indx] = cport.id
          indx += 1
            #binding.pry
          break
        end
  
  #      <!-- upto 100 hubs only...after that something went wrong for sure -->
        cntr += 1
        break if cntr>maxhubs
        
      end  #end while
  
      #binding.pry
  
    end   #end each do
    
    #now, at this point we have a list of ports that carry fibers going to the direction of devB
    #...using this list, build the list of connections too
    
    indx = 0
    @portList.each do |prtID|
      
      fbrO = Devport.find_by_id(prtID).fiber_out_id
      
      connID = Fiberstrand.find_by_id(fbrO).connection_id
      next if connID==0 #exlcude those fibers belonging to no connections
      
      @connList[indx] = Fiberstrand.find_by_id(fbrO).connection_id
      @customerList[indx] = Connection.find_by_id(@connList[indx]).customer_id
      
      indx +=1
      
    end
    
    @count = indx-1
    
    @srcDev = Device.find_by_id(devaID)
    @dstDev = Device.find_by_id(devbID)
    @srcLocation = Location.find_by_id(@srcDev)
    @dstLocation = Location.find_by_id(@dstDev)

    #binding.pry
  
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
      
      if (!bkh.nil?)
        @message += "<td align='left'>" + view_context.link_to(bkh.name.to_s, bkh)   + "</td>"
        @message += "<td align='center'>" + bktype[bkh.bkh_type]   + "</td>"
      else
        @message += "<td align='left'> -- </td>"
        @message += "<td align='left'> -- </td>"
      end
      
      @message += "</tr>"

      num += 1
    end #end qres search

  end #end conn_searchprocess function


end
