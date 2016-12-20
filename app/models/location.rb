class Location < ActiveRecord::Base
    has_many :net_racks, dependent: :destroy
    has_many :cables
    
    validates_presence_of :name, :address, :location_type
    
    accepts_nested_attributes_for :net_racks
    
    def name_with_type
        "#{name} - #{location_type}"
    end
    
    
    
#--------------------------------------------------------------    
    #read an Excel file and import data (july 2016)
    def self.import_location(locname, loctype, locaddr, rfsBldg, rfsDate, noOfHomePassed, noOfHomeConnected)
        
        loc = Location.where("name LIKE '" + locname + "'" + "AND location_type LIKE '" + loctype + "'").first
        
        if loc.nil? #creat new location with the given info
          loc = create ([name: locname, location_type: loctype, address: locaddr, rfs_status: rfsBldg, rfs_date: rfsDate, home_passed: noOfHomePassed, home_connected: noOfHomeConnected]).first
          
        else
          loc.name= locname
          loc.location_type= loctype
          loc.address= locaddr 
          
          
        loc.rfs_status = "N/A" if (loc.rfs_status.nil? || loc.rfs_status.empty?)
        if (loctype.casecmp("MDU")==0 || loctype.casecmp("SDU")==0)
            loc.rfs_status = rfsBldg if (rfsBldg!="N/A")
        else
            loc.rfs_status = "N/A"
        end
          
          loc.rfs_date = rfsDate
          loc.home_passed = noOfHomePassed
          loc.home_connected = noOfHomeConnected
          
          loc.save
            
        end
        
        #binding.pry    
        loc.id  # return the location ID
        
    end
#--------------------------------------------------------------



    def self.search (q)
       
       qres = Location.where("name LIKE ?", "%" + q + "%")
       # binding.pry
        qres
    end


    def self.getFreePotrs(id)
       
       freePorts = []
       
       #return any ports with in or out parts set to nill or zero
       loc = find(id)
       
       #binding.pry
        i=0
        loc.net_racks.each do |nr|
            nr.devices.each do |dvc|
                dvc.devports.each do |prt|
                    if (prt.fiber_in_id.nil? || prt.fiber_out_id.nil? || prt.fiber_in_id==0 || prt.fiber_out_id==0)
                        freePorts[i] = prt.id 
                        i += 1
                    end
                end
            end
        end
        
        freePorts
    end

end
