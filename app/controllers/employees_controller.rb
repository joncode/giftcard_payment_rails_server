class EmployeesController < ApplicationController
  
  def invite_employee
    if params[:email] && params[:user_id]
      Resque.enqueue(EmailJob, 'invite_employee', params[:user_id], {:email => params[:email], :gift_id => params[:gift_id]})
    end
  end
  
end
