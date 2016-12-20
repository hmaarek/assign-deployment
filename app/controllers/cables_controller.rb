class CablesController < ApplicationController
  before_action :set_cable, only: [:show, :edit, :update, :destroy]

  # GET /cables
  # GET /cables.json
  def index
    @cables = Cable.all
  end

  # GET /cables/1
  # GET /cables/1.json
  def show
  end

  # GET /cables/new
  def new
    @cable = Cable.new
  end

  # GET /cables/1/edit
  def edit
  end

  # POST /cables
  # POST /cables.json
  def create
    @cable = Cable.new(cable_params)

    respond_to do |format|
      if @cable.save
        format.html { redirect_to @cable, notice: 'Cable was successfully created.' }
        format.json { render :show, status: :created, cable: @cable }
      else
        format.html { render :new }
        format.json { render json: @cable.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cables/1
  # PATCH/PUT /cables/1.json
  def update
    respond_to do |format|
      if @cable.update(cable_params)
        format.html { redirect_to @cable, notice: 'Cable was successfully updated.' }
        format.json { render :show, status: :ok, cable: @cable }
      else
        format.html { render :edit }
        format.json { render json: @cable.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cables/1
  # DELETE /cables/1.json
  def destroy
    
    #first, destroy all those fibers in that cable...
    #binding.pry
    #fibers = @cable.fiberstrands
    fibers = Fiberstrand.where("cable_id = " + @cable.id.to_s)
    
    fibers.each do |fiber|
      #fiber.destroy
      #binding.pry
      clearPortAndFiber(fiber)
      
    end
    
    #@cable.destroy
    respond_to do |format|
      format.html { redirect_to root_path, notice: 'Cable was Successfully Deleted.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cable
      @cable = Cable.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def cable_params
      params.require(:cable).permit(:name, :size, :location_a_id, :location_b_id)
    end
end
