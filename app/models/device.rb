class Device < ActiveRecord::Base
  belongs_to :net_rack
  has_many :devports, dependent: :destroy
  
  validates_presence_of :name, :device_type, :net_rack_id
  
  
  
  #----------------------------------------------
  def self.import_device(devname, rackID, devtype)
    
    #binding.pry
    dev = Device.where("net_rack_id = '" + rackID.to_s + "' AND name LIKE '" + devname + "'").first
    if dev.nil?
      dev = create ([name: devname, device_type: devtype, net_rack_id: rackID]).first
      
    else
      
      dev.name= devname
      dev.device_type= devtype
      dev.net_rack_id= rackID
      
      dev.save
      
    end
    
    dev.id  #return rack id
    
  end
  #-----------------------------------------------

  
      def name_with_type
        "#{name} - (Type:#{device_type})"
    end

end
