class BackhaulsController < ApplicationController
  before_action :set_backhaul, only: [:show, :edit, :update, :destroy]

  # GET /backhauls
  # GET /backhauls.json
  def index   #(index for backhauls)
    @backhauls = Backhaul.where("bkh_type = 0")
    @ShowBackhaulsOnly = true
  end

  def feeders  #(index for feeders)
    @backhauls = Backhaul.where("bkh_type = 1")
    @ShowBackhaulsOnly = false
    render "backhauls/index"
  end



  # GET /backhauls/1
  # GET /backhauls/1.json
  def show
    
    @connections = Connection.where("backhaul_id =" + @backhaul.id.to_s)
    @darkConns=0
    @liveConns=0
    @resrvConns=0
    @otherConns=0
    
    #HTML messages to be returned to view:
    @connHTMLData =""
    @liveHTMLData =""
    @reservedHTMLData =""
    @darkHTMLData =""
    @unknownHTMLData =""
    
    
    #----  produce 3 Html Messages to be returned to the view (connections/index):
    #   1. Live connections details
    #   2. Rerserved connections details
    #   3. Dark connection details
    
    
    if @backhaul.bkh_type == 0

      @connections.each do |conn|
        
        ustr = conn.status.upcase
        
        case ustr
          when "DARK"
            @darkConns += 1
            
          when "LIVE"
            @liveConns +=1 
            
          when "RESERVED"
            @resrvConns +=1
            
          else
            @otherConns +=1
        end
        
      end



      count=0
      @connections.each do |connection|

        customer = Customer.find_by_id(connection.customer_id)
        if customer.nil?
          cnam="--"
        else
          cnam=customer.name
        end
      
        firstPortID = connection.get_first_port
        if firstPortID>0 
          prt = Devport.find_by_id(firstPortID)
          locationA = Location.find_by_id(prt.location_id)
          locAname= locationA.name
        else
          locAname= "Not Found"
          locationA=nil
        end
        
        lastPortID = connection.get_last_port
        if lastPortID>0
          prt = Devport.find_by_id(lastPortID)
          locationB = Location.find_by_id(prt.location_id)
          locBname= locationB.name
        else
          locBname= "Not Found"
          locationB=nil
        end

          @connHTMLData ="<tr>"
          
          if connection.status.casecmp("Live")==0
            @connHTMLData += "<td align='center'>" + view_context.image_tag('/images/red_light_st.png') + "</td>"
          else
            if connection.status.casecmp("Reserved")==0
              @connHTMLData += "<td align='center'>" + view_context.image_tag('/images/blue_light_s.jpg') + "</td>"
            else
              if connection.status.casecmp("Dark")==0
                @connHTMLData += "<td align='center'>" + view_context.image_tag('/images/green_light_s.jpg') + "</td>"
              end
            end
          end
          @connHTMLData += "<td align='left'>" + count.to_s + "</td>"
          @connHTMLData += "<td align='center'>" +  view_context.link_to(connection.name, connection) + "</td>"
          @connHTMLData += "<td align='center'>" + view_context.link_to(cnam, customer) + "</td>"
          
          #binding.pry
          
          if !locationA.nil?
            @connHTMLData += "<td align='center'>" + view_context.link_to(locAname, locationA)+ "</td>"
          else
            @connHTMLData += "<td align='center'>" + locAname + "</td>"
          end
          
          if !locationB.nil?
            @connHTMLData += "<td align='center'>" + view_context.link_to(locBname, locationB) + "</td>"
          else
            @connHTMLData += "<td align='center'>" + locBname + "</td>"
          end


          if connection.status.casecmp("Live")==0
            @connHTMLData += "<td align='center'><font color ='OrangeRed'>" + connection.status + "</font></td>"
          else
            if connection.status.casecmp("Reserved")==0
              @connHTMLData += "<td align='center'><font color ='Blue'>" + connection.status + "</font></td>"
            else
              if connection.status.casecmp("Dark")==0
                @connHTMLData += "<td align='center'><font color ='ForestGreen'>" + connection.status + "</font></td>"
              end
            end
          end


          
          @connHTMLData += "<td align='left'>" + connection.description + "</td>"
          @connHTMLData += "<td align='center'>" + connection.request_category + "</td>"
          connection.fiber_type="N/A" if connection.fiber_type.nil?
          @connHTMLData += "<td align='center'>" + connection.fiber_type + "</td>"
          @connHTMLData += "<td align='center'><a href='http://10.50.100.10:8080/WorkOrder.do?woMode=viewWO&woID='" + connection.request_id.to_s + " target='_blank'>" + connection.request_id.to_s + "</td>"
          if (logged_in? && current_user.user_type<=1)
            @connHTMLData += "<td>" + view_context.link_to(view_context.image_tag("/images/Edit_s2.png"), edit_connection_path(connection)) + "</td>"
          end
        @connHTMLData += "</tr>"
        
        #store the table into the right HTML message
        ustr = connection.status.upcase
        case ustr
        when "DARK"
          @darkHTMLData += @connHTMLData
          
        when "LIVE"
          @liveHTMLData += @connHTMLData
          
        when "RESERVED"
          @reservedHTMLData += @connHTMLData
          
        else
          @unknownHTMLData += @connHTMLData
        end
        
        count += 1
        
      end #end connections loop
      
      
    else # if bk_type = 0 ---------------------------------
#-----this is a feeder....reformat messages to match feeder details report---------
  #hashes....
  #NOTE: (25Aug2016): Only MDUs and SDUs
        buildingNames = {}            #1.Building names and location IDs
        dropFiberType = {}            #2.Drop Fiber Type (last cable size)
        totalImplemented = {}         #3.sum of fibers terminated on this building do this by counting the number of times that location was found
        buildingLiveConns={}          #4.Total Active (Live) fibers
        buildingResrvConns={}         #5.Total Reserved Fibers
        #cal: buildingReservedAndLive = {}  #6.Total Live + Reserved
        #cal: remainingFiber = {}     #7. Remianing Fiber (3 - 6)
        totalGPON = {}                #8.sum of GPON fibers for that building
        totalLiveGPON={}              #9.sum of type=GPON && status = Live fibers for that building
        totalReservedGPON={}          #9`.sum of type=GPON && status = reserved fibers for that building
        #cal: remainingGPON = {}      #10.sum of GPON(type) && Dark(status) fibers for that building
        totalP2P = {}                 #11.sum P2P fibers for that building
        totalLiveP2P ={}              #12.sum of type=P2P && status = Live fibers for that building
        totalReservedP2P ={}          #12`.sum of type=P2P && status = reserved fibers for that building 
        #cal: remainingP2P = {}       #13. remianing...calculate it
        #buildingDarkConns={}
        totalUnknownType={}           #14. Neither GPON nor P2P, not yet implemented (will find "N/A" in type)
        
        #26Sep2016: add cable sizes to dropped MDU, and donnt replace other dropped (on the same MDU) cable sized
        mduCable= {0=>"0"}  #create a hash with a fake initial value


      @connections.each do |connection|

        last_port = connection.get_last_port
        #1. building Name
        #binding.pry if last_port ==0
        #binding.pry if Devport.find_by_id(last_port).nil?
        bldng = Location.find(Devport.find(last_port).location_id)
        
        next if (bldng.location_type.casecmp("MDU") != 0 && bldng.location_type.casecmp("SDU") !=0)
        
        bName = bldng.name #---------1
        
        buildingNames[bName]=Location.find(Devport.find(last_port).location_id).id if buildingNames[bName].nil?
        
        #initialize to zeros if nil
        totalImplemented[bName] = 0 if totalImplemented[bName].nil?
        buildingLiveConns[bName]=0 if buildingLiveConns[bName].nil?
        buildingResrvConns[bName]=0 if buildingResrvConns[bName].nil?
        totalGPON[bName]=0 if totalGPON[bName].nil?
        totalLiveGPON[bName]=0 if totalLiveGPON[bName].nil?
        totalReservedGPON[bName]=0 if totalReservedGPON[bName].nil?
        totalP2P[bName]=0 if totalP2P[bName].nil?
        totalLiveP2P[bName]=0 if totalLiveP2P[bName].nil?
        totalReservedP2P[bName]=0 if totalReservedP2P[bName].nil?
        totalUnknownType[bName]=0 if totalUnknownType[bName].nil?
        dropFiberType[bName] = 0  if dropFiberType[bName].nil? #init

        
        #2. Dropped fiber Size: (26Sep2016:- Need to add each terminated cable size, donnot take the minimum)
        prt = Devport.find(last_port)
        fiberin = Fiberstrand.find(prt.fiber_in_id)
        cbl = Cable.find(fiberin.cable_id)
        
        if (!(cbl.name.downcase.include? "propose"))
          if (mduCable[cbl.id].nil?)
            if dropFiberType[bName].nil?
              dropFiberType[bName] = cbl.size
            else
              dropFiberType[bName] += cbl.size  #---------2
            end
            mduCable[cbl.id]=bName
          end
          #3.total implemented fibers
          totalImplemented[bName] += 1
        end
        
        #####dropFiberType[bName] = cbl.size  #---------2

        #28Sep2016: moved up into the condition of "propose", only account the actual implemented
        #3.total implemented fibers
        #totalImplemented[bName] += 1

        #4. live connections
        buildingLiveConns[bName] += 1 if connection.status.casecmp("Live")==0
        
        #5. Reserved connections
        buildingResrvConns[bName] += 1 if connection.status.casecmp("RESERVED")==0


        if connection.fiber_type.casecmp("GPON")==0
          #8. Sum of GPONs
          totalGPON[bName] += 1 
              
          #9. sum of type=GPON && status = Live fibers for that building
          (totalLiveGPON[bName] += 1) if connection.status.casecmp("Live")==0
        
          #9`  ....Reserved
          (totalReservedGPON[bName] += 1) if connection.status.casecmp("RESERVED")==0    
        end
        
        #11. sum P2P fibers for that building
        if connection.fiber_type.casecmp("P2P")==0   
            totalP2P[bName] += 1           #------11

          #12. sum of P2P & Live
          (totalLiveP2P[bName] += 1) if connection.status.casecmp("Live")==0        #-------12

          #12`. sum of P2P & Reserved
          (totalLiveP2P[bName] += 1) if connection.status.casecmp("RESERVED")==0        #-------12

        end
        
        #14. (27 Aug 2016)
        if connection.fiber_type.casecmp("N/A")==0
          totalUnknownType[bName] +=1
        end


      end   #end of @connections main loop
      
  #---------prepare HTML parts (messages):--------------------------
      count=0
      buildingNames.each do |h_building|
      
        count +=1
        building = h_building[0]
        buildingObj = Location.find_by_id(h_building[1])
      
        #do separate calculations here, so that we can relate to the design...
        # _?? represents the column letter in the Excel sheet "Template for Feeder Capacity in Detail"
      #A. Building data
        droppedFiber_D        = dropFiberType[building]
        
      #B. Cable Data
        totalImplemented_E    = totalImplemented[building]
        totalLive_F           = buildingLiveConns[building]
        totalReserved_G       = buildingResrvConns[building]
        totalAllocatedFiber_H = totalLive_F + totalReserved_G
        remainingFiber_I      = totalImplemented_E - totalAllocatedFiber_H
        if totalImplemented_E >0
          percentageAllocated_J   = divide((totalAllocatedFiber_H * 100) , totalImplemented_E)
        else
          percentageAllocated_J=0
        end
      #C. GPON Data
        totalGPON_K           = totalGPON[building]
        liveGPONFiber_L       = totalLiveGPON[building]
        reservedGPONFiber_M   = totalReservedGPON[building]
        totalAllocatedGPON_N  = liveGPONFiber_L + reservedGPONFiber_M
        remainingGPON_O       = totalGPON_K - totalAllocatedGPON_N
        percentageAllocGPON_P = 0
        percentageAllocGPON_P = divide((totalAllocatedGPON_N*100) , totalGPON_K) #if totalGPON_K>0
      #D. P2P Data
        totalP2P_Q            = totalP2P[building]
        liveP2PFiber_R        = totalLiveP2P[building]
        reservedP2PFiber_S    = totalReservedP2P[building]
        totalAllocatedP2P_T   = liveP2PFiber_R + reservedP2PFiber_S
        remainingP2P_U        = totalP2P_Q - totalAllocatedP2P_T
        percentageAllocP2P_V  = 0
        percentageAllocP2P_V  = divide((totalAllocatedP2P_T * 100) , totalP2P_Q) #if totalP2P_Q > 0
        
        homePassed = (((totalGPON_K/3).to_i)*30) + totalP2P_Q
        
        
        
        #binding.pry
        @connHTMLData += "<td align='center'>" + count.to_s + "</td>"
        
        
        #put a RFS flag...
        if buildingObj.rfs_status.casecmp("Yes")==0
          @connHTMLData += "<td align='center'> <img src='/images/Yes_25x.jpg'></td>"
        else
          @connHTMLData += "<td align='center'> <img src='/images/No_25x.jpg'></td>"
        end
        
        
      #coloring...
        #1. dropped-fiber strange case when we have implemented more than the fiber (planned case)
        dropColor = "Black"
        #binding.pry
        dropColor = "OrangeRed" if dropFiberType[building] < totalImplemented[building]
        #2. Percentage coloring. Any percent >= 80% should show in red
        pAllocColor = "Black"
        pAllocColor = "OrangeRed" if percentageAllocated_J >= 80
        pAllocGPONColor = "Black"
        pAllocGPONColor = "OrangeRed" if percentageAllocGPON_P >= 80
        pAllocP2PColor = "Black"
        pAllocP2PColor = "OrangeRed" if percentageAllocP2P_V >= 80
        

        
        
        @connHTMLData += "<td align='center'>" +  view_context.link_to(building, buildingObj)  + "</td>"  # building + "</td>"
        @connHTMLData += "<td align='center'>" + homePassed.to_s + "</td>"
        @connHTMLData += "<td align='center'>" + droppedFiber_D.to_s + "</td>"
        @connHTMLData += "<td align='center'><font color = " + dropColor + ">" + totalImplemented_E.to_s + "</font></td>"
        @connHTMLData += "<td align='center'>" + totalLive_F.to_s + "</td>"
        @connHTMLData += "<td align='center'>" + totalReserved_G.to_s + "</td>"
        @connHTMLData += "<td align='center'>" + totalAllocatedFiber_H.to_s + "</td>"
        @connHTMLData += "<td align='center'>" + remainingFiber_I .to_s + "</td>"
        @connHTMLData += "<td align='center'><font color = " + pAllocColor + ">" + percentageAllocated_J.to_s + "% </td>"
        @connHTMLData += "<td align='center'>" + totalGPON_K.to_s + "</td>"
        @connHTMLData += "<td align='center'>" + liveGPONFiber_L.to_s + "</td>"
        @connHTMLData += "<td align='center'>" + reservedGPONFiber_M.to_s + "</td>"
        @connHTMLData += "<td align='center'>" + totalAllocatedGPON_N.to_s + "</td>"
        @connHTMLData += "<td align='center'>" + remainingGPON_O.to_s + "</td>"
        @connHTMLData += "<td align='center'><font color = " + pAllocGPONColor + ">" + percentageAllocGPON_P.to_s + "% </td>"
        @connHTMLData += "<td align='center'>" + totalP2P_Q.to_s + "</td>"
        @connHTMLData += "<td align='center'>" + liveP2PFiber_R.to_s + "</td>"
        @connHTMLData += "<td align='center'>" + reservedP2PFiber_S.to_s + "</td>"
        @connHTMLData += "<td align='center'>" + totalAllocatedP2P_T.to_s + "</td>"
        @connHTMLData += "<td align='center'>" + remainingP2P_U.to_s + "</td>"
        @connHTMLData += "<td align='center'><font color = " + pAllocP2PColor + ">"  + percentageAllocP2P_V.to_s + "% </td>"
        @connHTMLData += "<td align='center'>" + totalUnknownType[building].to_s + "</td>"  #added 27 Aug 2016
        @connHTMLData += "</tr>"
        
      end      
      
      @liveHTMLData = @connHTMLData
    
    end   #end of if backhaul type is Feeder
    
    #-------------------------------------------
    
    render "connections/index"
    
  end

  def new
    @backhaul = Backhaul.new
  end


 # POST /backhauls
  # POST /backhauls.json
  def create
    @backhaul = Backhaul.new(backhaul_params)

    respond_to do |format|
      if @backhaul.save
        format.html { redirect_to @backhaul, notice: 'Backhaul was successfully created.' }
        format.json { render :show, status: :created, backhaul: @backhaul }
      else
        format.html { render :new }
        format.json { render json: @backhaul.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /backhauls/1
  # PATCH/PUT /backhauls/1.json
  def update
    respond_to do |format|
      if @backhaul.update(backhaul_params)
        format.html { redirect_to @backhaul, notice: 'Backhaul was successfully updated.' }
        format.json { render :show, status: :ok, backhaul: @backhaul }
      else
        format.html { render :edit }
        format.json { render json: @backhaul.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /backhauls/1
  # DELETE /backhauls/1.json
  def destroy
    #delete all cables and connections attached to that backhaul
    #1. delete this backhaul's cables:
    cables = Cable.where("backhaul_id =" + @backhaul.id.to_s)
    cables.each do |cable|
      cable.destroy
    end
    
    #2. delete this backaul's connections
    connections = Connection.where("backhaul_id =" + @backhaul.id.to_s)
    connections.each do |conn|
      conn.destroy
    end
    
    @backhaul.destroy
    respond_to do |format|
      format.html { redirect_to backhauls_url, notice: 'Backhaul was successfully destroyed.' }
      format.json { head :no_content }
    end
    
    #after backhaul is deleted, clean all ports...
    
    Devport.all.each do |port|
    
      port.destroy if (port.fiber_in_id==0  || Fiberstrand.find_by_id(port.fiber_in_id).nil?) && (port.fiber_out_id==0  || Fiberstrand.find_by_id(port.fiber_out_id).nil?)
    
    end
    
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_backhaul
      @backhaul = Backhaul.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def backhaul_params
      params.require(:backhaul).permit(:name, :bkh_type ,:rfs_status,:ring_id ,:descript)
    end
    
    
    def divide (nom, dnom)
      
      if (dnom == 0 || dnom.nil?)
        res = 0
      else
        res = (nom.to_f / dnom).ceil
      end
    
      res
      
    end
    
    
    
end