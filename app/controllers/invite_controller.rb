class InviteController < ApplicationController
  
  def show
    number = 649387
    
    # remove the permalink add-number from the id
    id = params[:id].to_i - number
    @gift = Gift.find(id)
    @giver = @gift.giver
    
    # check to see if its a mobile browser here
    # if so , change the render format to .mobile
    # add that format to the views folder and add to respond_to
    request.format   = :mobile if sniff_browser
    
    respond_to do |format|
      format.html # detail.html.erb
      format.json { render json: @gift }
    end

  end
  
  def invite_friend
    if params[:email] && params[:user_id]
      Resque.enqueue(EmailJob, 'invite_friend', params[:user_id], {:email => params[:email], :gift_id => params[:gift_id]})
    end
  end

  def display_email
    @email_title   = "Drinkboard Email Messenger"
    request.format = :email
    @header_text   = "#MobileGifting"
    @social = 1
    @web_view_route = create_webview_link

    case params[:template]
    when 'confirm_email'
      email_view    = "confirm_email"
      @user         = User.find(params[:var1])
      @header_text  = "Confirm Your Email Address"
      @social       = 0
    when 'forgot_password'
      email_view    = "forgot_password"
      @user         = User.find(params[:var1])
      @header_text  = ""
      @social       = 0
    when 'invoice_giver'
      email_view    = "invoice_giver"
      @header_text  = "Thank You for Your Purchase"
      @gift         = Gift.find(params[:var1])
    when 'notify_receiver'
      email_view    = "notify_receiver"
      @header_text  = "You have Received a Gift"
      @gift         = Gift.find(params[:var1])
    when 'notify_giver_order_complete'
      email_view    = "notify_giver_order_complete"
      @header_text  = "Your Gift Has Been Redeemed"
      @gift         = Gift.find(params[:var1])
    when 'notify_giver_created_user'
      email_view    = "notify_giver_created_user"
      @header_text  = "Your Gift has been Received"
      @gift         = Gift.find(params[:var1])
    else # join drinkboard email
      email_view    = "display_email"
      @web_view_route = "/webview/display_email"
    end

    respond_to do |format|
      format.email { render email_view }
    end
    
  end

  def create_webview_link
    "/webview/#{params[:template]}/#{params[:var1]}"
  end
  
end
