class UsersController < ApplicationController
  
  
  def new
  end
  
  
  def login
  end
  
  def processlogin
    
    #binding.pry
  
    @email = params[:email]
    @password = params[:password]
    
  end
  
end
