class LocationsController < ApplicationController
  before_action :set_location, only: [:show, :edit, :update, :destroy]

  # GET /locations
  # GET /locations.json
  def index
    @locations = Location.all
  end

  #GET locations/listrack
  def listrack
    @locations = Location.all
    @netracks = NetRack.all
    @devices = Device.all
    @devports = Devport.all
    @cables = Cable.all
    @fibers = Fiberstrand.all
   # binding.pry
  end


  # GET /locations/1
  # GET /locations/1.json
  def show
    
    #open the KML file
    @doc = Nokogiri::XML(File.open("public/COs.kml.xml"))
  
    #get all Location's coordinates  
    #this is from: http://stackoverflow.com/questions/14209033/ruby-nokogiri-converting-kml-to-csv
    @geo_lat=0
    @geo_lon=0
    @geo_elv=0
    maps_key = 'AIzaSyB_vdquEZaUk94_ZkY70xTO-dCexvN6JAs'
    map_base_url = 'https://www.google.com/maps/embed/v1/place'

    @doc.css('Placemark').each do |placemark|
      name = placemark.css('name')
      
      next if (@location.name.casecmp(name.text) != 0)
      
      coordinates = placemark.at_css('coordinates')
    
      if name && coordinates
        #print name.text + ","
        coordinates.text.split(' ').each do |coordinate|
          (@geo_lon,@geo_lat,@geo_elv) = coordinate.split(',')
          
          
        @url = map_base_url + '?key=' + maps_key + '&q=' + @geo_lat + ',' + @geo_lon
          break  #no need to continue, we found it all
        end
      end
    end
  
    #binding.pry
  
  end

  # GET /locations/new
  def new
    @location = Location.new
  end
  
  #GET /locations/searchprocess
  def searchprocess
    #binding.pry
    puts ("at Locations: new_search")

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
  
  def search
    #binding.pry
    #puts ("at Locations: search")
  end
    

  # GET /locations/1/edit
  def edit
  end

  # POST /locations
  # POST /locations.json
  def create
    @location = Location.new(location_params)
#binding.pry
    respond_to do |format|
      if @location.save
        format.html { redirect_to @location, notice: 'Location was successfully created.' }
        format.json { render :show, status: :created, location: @location }
      else
        format.html { render :new }
        format.json { render json: @location.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /locations/1
  # PATCH/PUT /locations/1.json
  def update
    respond_to do |format|
      if @location.update(location_params)
        format.html { redirect_to @location, notice: 'Location was successfully updated.' }
        format.json { render :show, status: :ok, location: @location }
      else
        format.html { render :edit }
        format.json { render json: @location.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /locations/1
  # DELETE /locations/1.json
  def destroy
    #@netracks = @location.net_racks.all
    #binding.pry
    #@netracks.destroy.all
    @location.destroy
    respond_to do |format|
      format.html { redirect_to locations_url, notice: 'Location was successfully destroyed.' }
      format.json { head :no_content }
    end
  end



  def list_free_ports
    
    list_free_ports_withloc(params[:id].to_i)
    
  end


  def list_free_ports_withloc (loc)
    
    #binding.pry
    
    t1 = Time.new
    
    freePorts = []
    @ports_A = []
    @ports_B = []
    
    @location = Location.find(loc)

    freePorts= Location.getFreePotrs(@location.id)
    

    indxa=0
    indxb=0
    
    freePorts.each do |prtID|
      prt = Devport.find(prtID)
      if prt.fiber_in_id > 0
        @ports_A[indxa] = prt
        indxa += 1
      elsif prt.fiber_out_id >0
        @ports_B[indxb] = prt
        indxb +=1
      end
    end
    
    t2 = Time.new
    
    puts "Controller function list_free_ports too:" + ((t2-t1) * 100).to_s + " milliseconds to finish"
    
    @ports_A
    @ports_B


    #binding.pry
  
  end
  
  
  def report_free_ports
    
   #binding.pry
   
    #@freePorts = []
    locID = params[:loc]
    #@location = Location.find(locID)
    #@freePorts= Location.getFreePotrs(locID)


    list_free_ports_withloc(locID)
    
    #binding.pry
    
    @location = Location.find(locID)
    
    #xls export locations-----------
    respond_to do |format|
      format.html
      format.xlsx{
      response.headers['Content-Disposition'] = 'attachment; filename="PortMap.xlsx"'
    }
    end
  #--------------------------------  

  #render "locations/list_free_ports.html"
    
  end
  
  
  def batchports
    
    #binding.pry
    
    params.each do |key, value|
      
    next if !(key[0,3]=="id_")  # get only the ports from params
        
    port_B_id = key[3,100].to_i
    port_A_id = value.to_i
    
    port_B = Devport.find(port_B_id)



  #if user has decided to connect that port...
    if (!port_A_id.nil? && port_A_id>0)

      port_A = Devport.find(port_A_id)
      
      loc = Location.find(port_B.location_id)
      locID = loc.id

      #prepare the new dummy cable to carry the fiber between the 2 ports (Path_locationName_DeviceInName-DeiceOutName)
      patch_cable_name = "Patch_" + loc.name + "_" + Device.find(port_B.device_id).name + "-" + Device.find(port_A.device_id).name
    
    
      #binding.pry
      #return
      
      #try to create the cable (if it was not created before)
      cableID = Cable.import_cable(patch_cable_name, 288, locID, locID, 0)  #backhaul id = 0
      
      #add that fiber to the cable: [cablename_fiber_portOutName.portInName]
      fiberName = patch_cable_name + "_fiber_" + port_B.name + "." + port_A.name
      fiberID = Fiberstrand.import_fiber(fiberName, port_A.id, port_B.id, cableID, 0)  #connection ID = 0

  #now, use this fiberID to connect both ports
  #---the crfeation of the fiber will set everything correctly
  #---no need for this commented-out code below
      
      #see the map here (snapshot from debug): 
      # https://www.dropbox.com/s/hwuehs2dzeo4xsy/port_A_port_B-Patching.png?dl=0
      #port_A.fiber_out_id = fiberID
      #port_B.fiber_in_id = fiberID
      
      #port_A.save
      #port_B.save
      
      #fiber = Fiberstrand.find(fiberID)
      #fiber.porta = port_A.id
      #fiber.portb = port_B.id
      
      #fiber.save
      
    end
      
  
      
    end

    
  end


#here we connect same connections (conns with the same name) found on 2 
# backhauls with each other trough ports in and out
  def connectbackhauls
    
    locID = params[:id]
    loc = Location.find(locID)
    @location = loc
    
    list_free_ports_withloc(locID)
    
    #binding.pry
    #return
    
    
    #counters...
    #darkFibersA = 0
    #darkFibersB = 0
    @newlyConnectedFibers=0
    @fiberIDList=[]
    #@freeCapacityBetweenPoints=0
    
    
    #this brings  @ports_A  and  @ports_B
    #for every port in @ports_A, check the connID, and search for that in 
    # @ports_B, if matched...connect both ports with a new fiber, using the same
    # connID
    
    indx=0
    @ports_B.each do |prtB|
      
      #Loop only for those valid, live/reserved connections
        fbrIB = Fiberstrand.find(prtB.fiber_out_id)  #fiber_in on prtB should be zero
        connBID = fbrIB.connection_id
        next if connBID==0
        
        connB = Connection.find(connBID)
        
        if connB.status.casecmp("Dark")==0
          
          #darkFibersB += 1
          next 
        end
      
      @ports_A.each do |prtA|
        
        next if (prtB ==0 || prtB.nil?)
        
        #get connection at fiber_out at A
        fbrOA = Fiberstrand.find(prtA.fiber_in_id)  #fiber_out on prtA should be zero
        connAID = fbrOA.connection_id
        next if connAID==0
        
        connA = Connection.find(connAID)
        
        if connA.status.casecmp("Dark")==0
          #darkFibersA += 1
          next
        end
        
        #binding.pry
        
        if connA.name.casecmp(connB.name)==0
          #found a matching connection on both sides...
          #connect both ports 
          interconnectConnections(connA, prtA, connB, prtB, loc)

          @newlyConnectedFibers +=1

          break  #end the portA loop as we have already connected the B port to that A port! Nov26,2016

        end
        
  
      end  #@port_A loop

      indx += 1

    end #@port_B loop

    #return the correct counters...
    #@freeCapacityBetweenPoints = darkFibersA
    #@freeCapacityBetweenPoints = darkFibersB if darkFibersB < darkFibersA

    
  end



#------------------------------------------------------------------------------
# Use one connection (the olderst) and erase the other.
# note: be careful in erasing not erase fibers, ports...etc.!
  # --> for backhauls, use the backhaul of the old connection...
  def interconnectConnections (connA, prtA, connB, prtB, loc)
    
    #use the connid which was created first (older)
    conn = connA
    conn= connB if connB.created_at < connA.created_at
    
    locID = loc.id
    
    devAName = Device.find(prtA.device_id).name
    devBName = Device.find(prtB.device_id).name
    
    patch_cable_name = "Patch_" + loc.name + "_" + devAName + "-" + devBName
    patch_backhaul_name = "Interconnect_Backhaul-" + loc.name + "_" + devAName + "-" + devBName
  
    #                                                 rfsStatus, Type, desc, ringID
    #bkhID = Backhaul.import_backhual(patch_backhaul_name, "Yes" , 0, "Auto Created while interconnecting location: " + loc.name, 0)
    #27 Nov, use backhaul id of the old connection
    bkhID =  conn.backhaul_id  #use the primary bkhID...
    
    #and then place an entery into the Junction Table to record both backhauls for the connId
    #...the conn now transverses 2 bakhauls...
    bkhID2 = connB.backhaul_id
    BkhConnInter.link_conn_to_bkh(conn.id, bkhID)
    BkhConnInter.link_conn_to_bkh(conn.id, bkhID2)
    
    
    
    
    
    #try to create the cable (if it was not created before)
    cableID = Cable.import_cable(patch_cable_name, 288, locID, locID, bkhID)  #backhaul id = 0
    
    #add that fiber to the cable: [cablename_fiber_portOutName.portInName]
    fiberName = patch_cable_name + "_fiber_" + prtA.name + "." + prtB.name
    #the import function creates the fiber and connects the ports too
    #binding.pry
    fiberID = Fiberstrand.import_fiber(fiberName, prtA.id, prtB.id, cableID, conn.id)  #connection ID = 0
    @fiberIDList[@newlyConnectedFibers] = fiberID
    
    #now that we have connected both ports, remove prtB from the list so we don't connect it again
    #prtB=0
    #@port_B[indx]=0  #rabena yostr!
    
    #and now, very importantly, delte the connection that we have replaced...
    # first...which one did we replace?
    conn_del = connA
    conn_del = connB if conn == connA
    
    
    
    
    #Nov 26, 2016, replace all connId of old conn (conn_del) to be the new conn (max 50 hubs)
    fout = Fiberstrand.find(prtB.fiber_out_id)
    i=0
    while i < 50
      #break if fout == 0
      
      #(Fiberstrand.find(fout.id)).connection_id = conn.id
      fout.connection_id = conn.id
      fout.save
      prtbid = Fiberstrand.find(fout.id).portb
      
      prtb = Devport.find(prtbid)
      break if prtb.fiber_out_id ==0 
      fout = Fiberstrand.find(prtb.fiber_out_id)
      
      i += 1
    end
    
    #if we existed the loop without finding the end...PANIC          
    raise StandardError.new("Could not find end of connection (no fiber_out is zero)") if i >= 50
    
    
    #no need of that conn now, delete it
    conn_del.destroy
    
  end
#------------------------------------------------------------------------------

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_location
      @location = Location.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def location_params
      params.require(:location).permit(:name, :address, :location_type, :rfs_status, :rfs_date, :home_passed, :home_connected)
    end




end


  