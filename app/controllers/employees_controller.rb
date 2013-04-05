class EmployeesController < ApplicationController
  
  def invite_employee
    if params[:email] && params[:user_id]
    	# >>>>>> NEED THE PROVIDER ID FOR THIS TO WORK !!!!!!
      # Resque.enqueue(EmailJob, 'invite_employee', params[:user_id], {:provider_id => @provider.id, :email => params[:email], :gift_id => params[:gift_id]})
    end
  end
  
end
