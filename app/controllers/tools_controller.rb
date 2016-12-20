class ToolsController < ApplicationController
  
  def mergedataform
  end
  
  
  
  def mergedataproc
    
    #binding.pry
    
    itemA = params[:itemA]
    itemB = params[:itemB]
    
    #dispatch to the propoer function depending on params[:ItemType][:type]
     # ['Customer', 'Connection', 'Backhaul/Feeder', 'Cable', 'Location'] 
    case  params[:ItemType][:type]
    
      when "Customer"
        mergeCustomer(itemA, itemB)
        
      when "Connection"
      
      when "Backhaul/Feeder"
        
        
      when "Cable"
        
      when "Location"
    
    
    else
      #error?
      
    end
    
  end
  
  
  def mergeCustomer (itemA, itemB)
    
    @message =""                                                                                                                    
    weAreLeaving = false
    
    selcItmA = Customer.where("name = '" + itemA + "'").first
    selcItmB = Customer.where("name = '" + itemB + "'").first
    
    if selcItmA.nil?
      @message = "Could not find ItemA [" + itemA + " ]"
      weAreLeaving = true
    end
    
    if selcItmB.nil?
      
      @message += "<br>" if weAreLeaving
      @message += "Could not find ItemB [" + itemB + " ]"
      return
    end
  
    return if weAreLeaving
    
    if selcItmA.id == selcItmB.id
      
      @message = "Items are identical...done nothing!"
      return
      
    end
    
    
    #at this point, we have everything set...let's do it...
    # Tables to be changed: [connections , contracts]  (from schema.rb)
    
    #1. Connection Table...
    bList = Connection.where("customer_id = " + selcItmB.id.to_s)
    counter = 0
    bList.each do |bItem|
      bItem.customer_id = selcItmA.id
      bItem.save
      counter += 1
    end
    
    @message = "-Changed " + counter.to_s + " Connections"
  
    #2. Contracts Table...
    counter = 0
    bList = Contract.where("customer_id = " + selcItmB.id.to_s)
    counter = 0
    bList.each do |bItem|
      bItem.customer_id = selcItmA.id
      bItem.save
      counter += 1
    end
    @message += "<br>-Changed " + counter.to_s + " Contract"


  end
  
  
  
  
  
end
