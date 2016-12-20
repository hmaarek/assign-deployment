class ConnectionsController < ApplicationController
  before_action :set_connection, only: [:show, :edit, :update, :destroy]

  # GET /connections
  # GET /connections.json
  def index
    @connections = Connection.all
  end

  # GET /connections/1
  # GET /connections/1.json
  def show
  end

  def new
    @connection = Connection.new
  end


 # POST /connections
  # POST /connections.json
  def create
    @connection = Connection.new(connection_params)

    respond_to do |format|
      if @connection.save
        format.html { redirect_to @connection, notice: 'Connection was successfully created.' }
        format.json { render :show, status: :created, connection: @connection }
      else
        format.html { render :new }
        format.json { render json: @connection.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /connections/1
  # PATCH/PUT /connections/1.json
  def update
    respond_to do |format|
      if @connection.update(connection_params)
        format.html { redirect_to @connection, notice: 'Connection was successfully updated.' }
        format.json { render :show, status: :ok, connection: @connection }
      else
        format.html { render :edit }
        format.json { render json: @connection.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /connections/1
  # DELETE /connections/1.json
  def destroy
    #binding.pry
    #clear all connection_id attribute for evey fiber linked to that connection
    #24Aug2016: no....delete the fiber instead of "clearing" it
    flist = Fiberstrand.where("connection_id = " + @connection.id.to_s)
    flist.each do |fiber|
      #fiber.connection_id = 0
      #fiber.save
      #fiber.destroy
      clearPortAndFiber(fiber)
    end
    
    @connection.destroy
    respond_to do |format|
      format.html { redirect_to connections_url, notice: 'Connection was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_connection
      @connection = Connection.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def connection_params
      params.require(:connection).permit(:name, :customer_id, :status, :description, :request_category, :request_id)
    end
end