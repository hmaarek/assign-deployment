class ApplicationController < ActionController::Base
   before_action :check_login, only: [:show, :index, :new, :edit, :update, :destroy, :import,:impproces]
   #before_action :check_user_type, only: [:edit, :update, :destroy, :import,:impproces]
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  include SessionsHelper
  
  
  def check_login
     # binding.pry
      if (!logged_in?)
          flash[:danger] = 'You must be logged-in. Please Login first:'
          redirect_to login_path and return      #"/404.html"
      else 
          if (logged_in? && current_user.user_type>1 && (["new", "edit", "update", "destroy", "import", "impproce"].include? params[:action]))
            flash[:danger] = 'You must be Super User to access this section. Please Login:'
            redirect_to login_path        #"/404.html"
          end
      end
  end
  
  def check_user_type
      unless (logged_in? && current_user.user_type<=1)
        flash[:danger] = 'You must be Super User to access this section. Please Login:'
        redirect_to login_path        #"/404.html"
      end
  end



    def clearPortAndFiber(fiber)
        
        #binding.pry
        
        #1. free port a 
        prt = Devport.find_by_id(fiber.porta)
        if (!prt.nil?)
          prt.fiber_in_id = 0 if (prt.fiber_in_id == fiber.id)
          prt.fiber_out_id = 0 if (prt.fiber_out_id == fiber.id)
          
          prt.save
          
        end
        #24Aug 2016: delete the port of both fibers are delted
        prt.destroy if (prt.fiber_in_id == 0 && prt.fiber_out_id==0)
        
        
        #2. free port b 
        prt = Devport.find_by_id(fiber.portb)
        if (!prt.nil?)
          prt.fiber_in_id = 0 if (prt.fiber_in_id == fiber.id)
          prt.fiber_out_id = 0 if (prt.fiber_out_id == fiber.id)
          
          prt.save
          
        end
        
        #24Aug 2016: delete the port of both fibers are delted
        prt.destroy if (prt.fiber_in_id == 0 && prt.fiber_out_id==0)
        
    end
  
end
