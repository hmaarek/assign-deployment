class DevicesController < ApplicationController
     before_action :set_device, only: [:show, :edit, :update, :destroy]

    def show
    end

  # GET /net_rack/:ner_rack_id/devicess
  # GET /net_racks/:net_rack_id/devicess.xml  (what is this????)
  def index
    #1st you retrieve the location thanks to params[:location_id]
    net_rack = NetRack.find(params[:net_rack_id])
    #2nd you get all the net_racks of this location
    @devices = net_rack.devices

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @net_racks }
    end
  end
     
    def new
      #location = Location.find(params[:location_id])
      # binding.pry
      
      @net_rack = NetRack.find(params[:net_rack_id])
      #@device = Device.new
      @device = @net_rack.devices.build

      #location = Location.find(params[:location_id])
      #net_rack = NetRack.find(params[:net_rack_id])
      #@device = location.net_rack.devices.build
      
      #binding.pry      

      #respond_to do |format|
      #  format.html
      #  format.xml {render :xml => @device}
      #end
    end
   
  # GET /devices/1/edit
  def edit
    #if !(logged_in? && current_user.user_type<=1)
    #  redirect_to "/404.html"
    #end
  end

    def create
      #if !(logged_in? && current_user.user_type<=1)
      #  redirect_to "/404.html"
      #end

    #binding.pry      
      net_rack =  NetRack.find(params[:net_rack_id]) #NetRack.find_by_id(params[:net_rack_id])
      @device = net_rack.devices.create(params[:device].permit(:name, :device_type, :net_rack_id))
      
      
        respond_to do |format|
            if @device.save
                #format.html { redirect_to([@device.net_rack, @device], notice: 'Termination Device was successfully created.') }
                format.html { redirect_to(@device, notice: 'Termination Device was successfully created.') }
                format.xml  { render :xml => @device, :status => :created, :net_rack => [@device.net_rack, @device] }
            else
                format.html { render :action => "new" }
                format.xml  { render :xml => @device.errors, :status => :unprocessable_entity }       
            end
        end
    end

  # PUT /net_racks/:net_rack_id/devices/:id
  # PUT /net_racks/:net_rack_id/devices/:id.xml
  def update

    #if !(logged_in? && current_user.user_type<=1)
    #  redirect_to "/404.html"
    #end


    #1st you retrieve the net_rack thanks to params[:net_rack_id]
    #net_rack = NetRack.find(params[:net_rack_id])
    #2nd you retrieve the device thanks to params[:id]
    #@device = net_rack.devices.find(params[:id])

    respond_to do |format|
      # if @device.update_attributes(params[:device])
      if @device.update(device_params)
        #1st argument of redirect_to is an array, in order to build the correct route to the nested resource device
        format.html { redirect_to([@device], :notice => 'Termination Device was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @device.errors, :status => :unprocessable_entity }
      end
    end
  end


  # DELETE /net_racks/:net_rack_id/devices/1
  # DELETE /net_racks/:net_rack_id/devices/1.xml
  def destroy

    #if !(logged_in? && current_user.user_type<=1)
    #  redirect_to "/404.html"
    #end


    #1st you retrieve the net_rack thanks to params[:net_rack_id]
    #net_rack = NetRack.find(params[:net_rack_id])
    #2nd you retrieve the device thanks to params[:id]
    @device = Device.find(params[:id])
    net_rack = NetRack.find(@device.net_rack_id)

    @device.destroy
    
    #24Aug2016: delete dummy Racks if they are now empty
    net_rack.destroy if ((net_rack.name.casecmp("NA")==0 ||  net_rack.name.casecmp("N/A")==0) && net_rack.devices.count ==0)

    respond_to do |format|
      #1st argument reference the path /locations/:location_id/net_racks/
      format.html { redirect_to(net_rack_devices_url(net_rack)) }
      format.xml  { head :ok }
    end
  end



  private
    # Use callbacks to share common setup or constraints between actions.
    def set_device
      @device = Device.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def device_params
      params.require(:device).permit(:name, :device_type, :device_id)
    end
end
