class UserMailer < ActionMailer::Base

  default :css => 'email/email', :from => "noreplydrinkboard@gmail.com"

  def confirm_email(user)
      #  you've just joined the app , confirm your email 
    @user           = user
    @header_text    = "Confirm Your Email Address"
    @email_title    = "Drinkboard Email Messenger"
    @web_view_route = "#{TEST_URL}/webview/confirm_email/#{user.id}"
    @social         = 0 
    mail({
      :to => "#{@user.fullname} <#{@user.email}>",
      :subject => "Drinkboard: confirm your email"
    })       
  end

  def reset_password(user)
    @user           = user
    @header_text    = ""
    @social         = 0
    @email_title    = "Drinkboard Email Messenger"
    @web_view_route = "#{TEST_URL}/webview/forgot_password/#{user.id}"
    puts "reset_password -UserMailer-  for #{user.username}"
    mail({
      :to => "#{@user.fullname} <#{@user.email}>",
      :subject => "Drinkboard: password reset request"
    })
  end
    
  def invite_friend(user, friends_email, gift_id)
    @user = user
    @friends_email = friends_email

    @gift_id = gift_id
    mail({
      :to => "#{@friends_email}",
      :subject => "Your friend #{@user.first_name} invited you to drinkboard."
    })
  end
  
  def invite_employee(user,provider,employee_email)
    @user = user
    @provider = provider
    mail({
      :to => "#{employee_email}",
      :subject => "Drinkboard Employee Request"
    })
  end

  def invoice_giver(giver, gift)
    @user = giver
    @gift = gift
    @email_title    = "Drinkboard Email Messenger"

    @header_text    = "Purchase Complete , Thank You"
    @social         = 1
    @web_view_route = "/webview/invoice_giver/#{gift.id}"
    mail({
      :to => "#{@user.fullname} <#{@user.email}>",
      :subject => "Gift purchase complete"
    })
  end

  def notify_receiver(gift)
    @gift  = gift
    @email_title    = "Drinkboard Email Messenger"

    @header_text    = "You have Received a Gift"
    @social         = 1
    @web_view_route = "/webview/notify_receiver/#{gift.id}"
    mail({
      :to => "#{@gift.receiver_name} <#{@gift.receiver_email}>",
      :subject => "A Gift has been purchased for You!"
    })
  end

  def notify_giver_order_complete(giver, gift)
    @user = giver
    @gift = gift
    @email_title    = "Drinkboard Email Messenger"

    @header_text    = "Your Gift Has Been Redeemed"
    @social         = 1
    @web_view_route = "/webview/notify_giver_order_complete/#{gift.id}"
    mail({
      :to => "#{@user.fullname} <#{@user.email}>",
      :subject => "Gift Redeem complete"
    })    
  end

  def notify_giver_created_user(giver, gift)
    @user = giver
    @gift = gift
    @email_title    = "Drinkboard Email Messenger"

    @header_text    = "Your Gift has been Received"
    @social         = 1
    @web_view_route = "/webview/notify_giver_created_user/#{gift.id}"
    mail({
      :to => "#{@user.fullname} <#{@user.email}>",
      :subject => "Gift to #{@gift.receiver_name} has been received!"
    })    
  end

end

