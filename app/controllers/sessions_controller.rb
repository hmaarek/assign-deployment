class SessionsController < ApplicationController

  #skip_before_action :check_user_type, only: [:new, :create]
  skip_before_action :check_login, only: [:new, :create, :destroy]
  def new

  end

  def create

    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      # Log the user in and redirect to the user's show page.
    flash.now[:success] = 'Successful Login: '+ user.name # Not quite right!
    
    log_in user
    
    render 'welcome/index'
    else
      # Create an error message.
      #binding.pry
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end




  end
  



  def destroy
    #binding.pry
    log_out
    redirect_to root_url
  end
  
end
