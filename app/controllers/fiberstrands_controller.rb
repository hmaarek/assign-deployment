class FiberstrandsController < ApplicationController
      before_action :set_fiberstrand, only: [:show, :edit, :update, :destroy]

  # GET /cables/:cable_id/fiberstrands
  # GET /cables/:cable_id/fiberstrands.xml
  def index
    
    #1st you retrieve the cable thanks to params[:cable_id]
    cable = Cable.find(params[:cable_id])
    #2nd you get all the fiberstrands of this cable
    @fiberstrands = cable.fiberstrands


    #respond_to do |format|
    #  format.html # index.html.erb
    #  format.xml  { render :xml => @fiberstrands }
    #end
    
  end

  # GET /fiberstrands/1
  # GET /fiberstrands/1.json
  def show
  end

  # GET /fiberstrands/new
  def new
      cable = Cable.find(params[:cable_id])
      @fiberstrand = cable.fiberstrands.build

      respond_to do |format|
        format.html
        format.xml {render :xml => @fiberstrand}
      end
  end

  # GET /fiberstrands/1/edit
  def edit
  end

  # POST /fiberstrands
  # POST /fiberstrands.json
  def create
    cable = Cable.find(params[:cable_id])
    @fiberstrand = cable.fiberstrands.create(params[:fiberstrand].permit(:name, :porta, :portb,:cable_id,:connection_id))
    
    respond_to do |format|
      if @fiberstrand.save
        #format.html { redirect_to([@fiberstrand.cable, @fiberstrand], notice: 'Fiber was successfully connected.') }
        format.html { redirect_to(@fiberstrand, notice: 'Fiber was successfully connected.') }
        format.xml  { render :xml => @fiberstrand, :status => :created, :cable => [@fiberstrand.cable, @fiberstrand] }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @fiberstrand.errors, :status => :unprocessable_entity }       
      end
    end
    
  end

  # PUT /cables/:cable_id/fiberstrands/:id
  # PUT /cables/:cable_id/fiberstrands/:id.xml
  def update
    #binding.pry
    #1st you retrieve the cable thanks to params[:cable_id]
    #cable = Cable.find(params[:cable_id])
    #2nd you retrieve the fiberstrand thanks to params[:id]
    @fiberstrand = Fiberstrand.find(params[:id])

    respond_to do |format|
      # if @fiberstrand.update_attributes(params[:fiberstrand])
      if @fiberstrand.update(fiberstrand_params)
        #1st argument of redirect_to is an array, in order to build the correct route to the nested resource fiberstrand
        format.html { redirect_to([@fiberstrand], :notice => 'Rack was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @fiberstrand.errors, :status => :unprocessable_entity }
      end
    end
  end


  # DELETE /cables/:cable_id/fiberstrands/1
  # DELETE /cables/:cable_id/fiberstrands/1.xml
  def destroy
    #we are deleting this fiber...
    # then we need to free all ports connected to it


    clearPortAndFiber(@fiberstrand)

    #1st you retrieve the cable thanks to params[:cable_id]
    #cable = Cable.find(params[:cable_id])
    #2nd you retrieve the fiberstrand thanks to params[:id]
    @fiberstrand = Fiberstrand.find(params[:id])
    cable = Cable.find(@fiberstrand.cable_id)
    @fiberstrand.destroy

    respond_to do |format|
      #1st argument reference the path /cables/:cable_id/fiberstrands/
      format.html { redirect_to(cable_fiberstrands_url(cable)) }
      format.xml  { head :ok }
    end
  end



  private
    # Use callbacks to share common setup or constraints between actions.
    def set_fiberstrand
      @fiberstrand = Fiberstrand.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def fiberstrand_params
      params.require(:fiberstrand).permit(:name, :size, :cable_id, :connection_id)
    end

end
