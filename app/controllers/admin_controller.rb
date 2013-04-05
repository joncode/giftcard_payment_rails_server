class AdminController < ApplicationController
  	before_filter :signed_in_user
  	before_filter :admin_user?

	def show
	    @offset = params[:offset].to_i || 0
	    @page = @offset
	    paginate = 7
	    @providers = Provider.limit(paginate).offset(@offset)
	    if @providers.count == paginate
	      @offset += paginate 
	    else
	      @offset = 0
	    end
	end

	def test_emails
		
	end

	def run_tests
		# how to make these all
			# 1. email to "noreplydrinkboard@gmail.com"
			# 2. have gift data
			# 3. have provider data
		email = "noreplydrinkboard@gmail.com"
		user  = User.find_by_email "test@test.com"
		gifts = Gift.where(giver_id: user.id, receiver_id: user.id)
		gift  = gift[0]
		Resque.enqueue(EmailJob, 'confirm_email', 	user.id , 	{}) 
		Resque.enqueue(EmailJob, 'reset_password', 	user.id, 	{}) 
		Resque.enqueue(EmailJob, 'invite_friend', 	user.id , 	{:email => email, :gift_id => gift.id})
		Resque.enqueue(EmailJob, 'invite_employee', user.id , 	{:email => email, :gift_id => gift.id})
		Resque.enqueue(EmailJob, 'alert_giver', 	user.id  , 	{:gift_id => gift.id}) 
		Resque.enqueue(EmailJob, 'notify_receiver', user_id , 	{:gift_id => gift.id, :email => email}) 
		Resque.enqueue(EmailJob, 'notify_giver_order_complete', user.id , {:gift_id => gift.id}) 
		Resque.enqueue(EmailJob, 'invoice_giver', 	user.id  , 	{:gift_id => gift.id})
	end

end
