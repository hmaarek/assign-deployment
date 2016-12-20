class NetRacksController < ApplicationController
  before_action :set_net_rack, only: [:show, :edit, :update, :destroy]

  # GET /locations/:location_id/net_racks
  # GET /locations/:location_id/net_racks.xml
  def index
    #1st you retrieve the location thanks to params[:location_id]
    location = Location.find(params[:location_id])
    #2nd you get all the net_racks of this location
    @net_racks = location.net_racks

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @net_racks }
    end
  end

  # GET /net_racks/1
  # GET /net_racks/1.json
  def show
  end

  # GET /net_racks/new
  def new
    #binding.pry
      location = Location.find(params[:location_id])
      @net_rack = location.net_racks.build

      respond_to do |format|
        format.html
        format.xml {render :xml => @net_rack}
      end
  end
  
  #this was a test to see if we can have a drop down list for all locations to 
  #chose from...and create a net_rack from scratch -for later!
  #def newrack
  #    location = Location.first
  #    @net_rack = location.net_racks.build
  #
  #   # respond_to do |format|
  #    #  format.html
  #     # format.xml {render :xml => @net_rack}
  #    #end
  #end

  # GET /net_racks/1/edit
  def edit
  end

  # POST /net_racks
  # POST /net_racks.json
  def create
    #binding.pry
    location = Location.find(params[:location_id])
    @net_rack = location.net_racks.create(params[:net_rack].permit(:name, :size, :location_id, :rack_type))
    #@net_rack = NetRack.create(params[:net_rack].permit(:name, :size, :location_id))
    
    respond_to do |format|
      if @net_rack.save
        format.html { redirect_to(@net_rack, notice: 'Rack was successfully created.') }
        format.xml  { render :xml => @net_rack, :status => :created, :location => [@net_rack.location, @net_rack] }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @net_rack.errors, :status => :unprocessable_entity }       
      end
    end
    
    
    #@net_rack = NetRack.new(net_rack_params)
    #respond_to do |format|
    #  if @net_rack.save
    #    binding.pry      
    #    format.html { redirect_to location_net_rack_path(@net_rack.id), notice: 'Net rack was successfully created.' }
    #    format.json { render :show, status: :created, location: @net_rack }
    #  else
    #    format.html { render :new }
    #    format.json { render json: @net_rack.errors, status: :unprocessable_entity }
    #  end
    #end
  end

  # PUT /locations/:location_id/net_racks/:id
  # PUT /locations/:location_id/net_racks/:id.xml
  def update
    #binding.pry
    #1st you retrieve the location thanks to params[:location_id]
    ###location = Location.find(params[:location_id])
    #2nd you retrieve the net_rack thanks to params[:id]
    #@net_rack = net_racks.find(params[:id])

    respond_to do |format|
      # if @net_rack.update_attributes(params[:net_rack])
      if @net_rack.update(net_rack_params)
        #1st argument of redirect_to is an array, in order to build the correct route to the nested resource net_rack
        format.html { redirect_to([@net_rack], :notice => 'Rack was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @net_rack.errors, :status => :unprocessable_entity }
      end
    end
  end


  # DELETE /locations/:location_id/net_racks/1
  # DELETE /locations/:location_id/net_racks/1.xml
  def destroy
    #1st you retrieve the location thanks to params[:location_id]
    #location = Location.find(params[:location_id])
    #2nd you retrieve the net_rack thanks to params[:id]
    @net_rack = NetRack.find(params[:id])
    location = Location.find(@net_rack.location_id)
    @net_rack.destroy

    respond_to do |format|
      #1st argument reference the path /locations/:location_id/net_racks/
      format.html { redirect_to(location_net_racks_url(location)) }
      format.xml  { head :ok }
    end
  end



  private
    # Use callbacks to share common setup or constraints between actions.
    def set_net_rack
      @net_rack = NetRack.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def net_rack_params
      params.require(:net_rack).permit(:name, :size, :location_id, :rack_type)
    end
end
