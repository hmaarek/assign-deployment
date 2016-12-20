class DevportsController < ApplicationController
    before_action :set_devport, only: [:show, :edit, :update, :destroy]

    def show
    end
    
    #get 'devports/resetport/:id'
    def resetp
      @devports = Devport.all
    end

  # GET /devvices/:device_id/devports
  # GET /devvices/:device_id/devports.xml  (what is this????)
  def index
    #1st you retrieve the location thanks to params[:location_id]
    device = Device.find(params[:device_id])
    #2nd you get all the net_racks of this location
    @devports = device.devports

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @devices }
    end
  end
     
    def new
      #location = Location.find(params[:location_id])
      # binding.pry
      
      @device = Device.find(params[:device_id])
      #@device = Device.new
      @devport = @device.devports.build

      #binding.pry      

      #respond_to do |format|
      #  format.html
      #  format.xml {render :xml => @device}
      #end
    end
   
  # GET /devports/1/edit
  def edit
  end

    def create
      #binding.pry
      device = Device.find_by_id(params[:device_id])
      @devport = device.devports.create(params[:devport].permit(:name, :fiber_in_id, :fiber_out_id ,:device_id, :location_id))
      
      
        respond_to do |format|
            if @devport.save
                #format.html { redirect_to([@devport.device, @devport], notice: 'Port was successfully created.') }
                format.html { redirect_to(@devport, notice: 'Port was successfully created.') }
                format.xml  { render :xml => @devport, :status => :created, :device => [@devport.device, @devport] }
            else
                format.html { render :action => "new" }
                format.xml  { render :xml => @devport.errors, :status => :unprocessable_entity }       
            end
        end

        
    end

  # PUT /devices/:device_id/devports/:id
  # PUT /devices/:device_id/devports/:id.xml
  def update
    #1st you retrieve the device thanks to params[:device_id]
    #device = Device.find(params[:device_id])
    #2nd you retrieve the device thanks to params[:id]
    #@devport = device.devports.find(params[:id])

    respond_to do |format|
      if @devport.update(devport_params)
        #1st argument of redirect_to is an array, in order to build the correct route to the nested resource device
        format.html { redirect_to([@devport], :notice => 'Port was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @devport.errors, :status => :unprocessable_entity }
      end
    end
  end


  # DELETE /devices/:device_id/devports/1
  # DELETE /devices/:device_id/devports/1.xml
  def destroy
    #1st you retrieve the device thanks to params[:device_id]
    #device = Device.find(params[:device_id])
    #2nd you retrieve the devport thanks to params[:id]
    @devport = Devport.find(params[:id])
    device = Device.find(@devport.device_id)

    @devport.destroy
    
    #24Aug2016: delete unused, 
    device.destroy if (device.devports.count ==0)  #we've deleted the last port in that device, delete the device too

    respond_to do |format|
      #1st argument reference the path /locations/:location_id/net_racks/
      format.html { redirect_to(device_devports_url(device)) }
      format.xml  { head :ok }
    end
  end



  def cleanprts
    #display the number of ports that need to be "cleaned"
    #@dirtyPrts = 0
    #Devport.all.each do |prt|
     # fid = prt.fiber_in_id
      
      #@dirtyPrts += 1 if Fiberstrand.exists? id: fid
      #fiberI = Fiberstrand.find_by_id(prt.fiber_in_id)
      #fiberO = Fiberstrand.find_by_id(prt.fiber_out_id)
    
      #@dirtyPrts += 1 if fiberI.nil? #|| fiberO.nil?
    #end
    
    #@dirtyPrts
    
  end

  def cleanprtsproc

    #update progress bar...
    totalPorts = Devport.count
    i=0
    
    pusher_channel = "cleanports_process_#{current_user.id}"  # create a channel for real time update of the view, using pusher
    
    #binding.pry
    Devport.all.each do |prt|
      
      i += 1
      
      prt.fiber_in_id=0 if prt.fiber_in_id.nil?
      prt.fiber_out_id=0 if prt.fiber_out_id.nil?

      if (prt.fiber_in_id>0)
        fiber = Fiberstrand.find_by_id(prt.fiber_in_id)
        if fiber.nil?
          prt.fiber_in_id = 0
          #<%=prt.id%> fiber-in cleaned...<br>
          prt.save
        end
      end

      if (prt.fiber_out_id>0)
        fiber = Fiberstrand.find_by_id(prt.fiber_out_id)
        if fiber.nil?
          prt.fiber_out_id = 0
          #prt.id%> fiber-out cleaned...<br>
          prt.save
        end
      end

      increment = ((i*100)/(totalPorts))
      Pusher.trigger(pusher_channel, 'update', {message: "cleaning port #{i.to_s} of #{totalPorts.to_s}", progress: increment}) #((i*100)/(spreadsheet.last_row-5)) })  
      
    end

#do we need this?????????? 26 Oct 2016 --------------
  #  #<!-- Now trigger a save action for all fibers to update the devport table with the correct fiber-in and fiber-out -->
  #  Fiberstrand.all.each do |fbr|
  #    #<!--fiber.touch-->
  #    fbr.save
  #  end

    
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_devport
      @devport = Devport.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def devport_params
      params.require(:devport).permit(:name, :fiber_in_id, :fiber_out_id,:devport_id, :location_id)
    end

end
