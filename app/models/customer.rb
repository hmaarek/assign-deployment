#https://github.com/thoughtbot/paperclip

class Customer < ActiveRecord::Base
    has_attached_file :avatar, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/images/NoImage_s.png"
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\Z/

  
  #run a query to build a list of all signed contracts by that customer in the 
  #creation (23 July)
  def list_contracts
    #contracts_list = Contract.find_by_id(id).location_a_id
    
    Contract.where("customer_id = " + id.to_s )
  end




  def self.import_customer(cust_name)
    
    #custid =0
    #if (cust_name =="VFQ")
    #  binding.pry
    #end
    cust = Customer.where("name LIKE '" + cust_name + "'").first
    if cust.nil?
      #crearting new customer
      cust = create ([name: cust_name]).first
    else
      cust.name = cust_name
      cust.save
    end
    #binding.pry    
    #return the customer ID
    cust.id 


  end




end
