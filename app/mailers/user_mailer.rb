class UserMailer < ActionMailer::Base

  prod      = "no-reply@drinkboard.com"
  EMAIL_TO  = "noreplydrinkboard@gmail.com"
  default :css => 'email/email', :from => prod

  def confirm_email(user)
      #  you've just joined the app , confirm your email 
    @user           = user
    @header_text    = "Confirm Your Email Address"
    @email_title    = "Drinkboard Email Messenger"
    @web_view_route = "#{TEST_URL}/webview/confirm_email/#{user.id}"
    @social         = 0 
    mail({
      :to =>  EMAIL_TO ,# "#{@user.fullname} <#{@user.email}>",
      :subject => "Drinkboard: confirm your email #{@user.fullname}"
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
      :to => EMAIL_TO, #"#{@user.fullname} <#{@user.email}>",
      :subject => "Drinkboard: password reset request #{@user.fullname}"
    })
  end
    
  def invite_friend(user, friends_email, gift_id)
    @user = user
    @friends_email = friends_email

    @gift_id = gift_id
    # :to => "#{@friends_email}",
    mail({
      :to => EMAIL_TO,
      :subject => "Your friend #{@user.first_name} invited you to drinkboard. #{@friends_email}"
    })
  end
  
  def invite_employee(user,provider,employee_email)
    @user = user
    @provider = provider
    # :to => "#{employee_email}",
    mail({
      :to => EMAIL_TO,
      :subject => "Drinkboard Employee Request #{employee_email}"
    })
  end

  def invoice_giver(giver, gift)
    @user           = giver
    @gift           = gift
    @email_title    = "Drinkboard Email Messenger"
    @cart           = @gift.ary_of_shopping_cart_as_hash
    @merchant       = @gift.provider
    @header_text    = "Purchase Complete , Thank You"
    @social         = 0
    @web_view_route = "#{TEST_URL}/webview/invoice_giver/#{gift.id}"
    # :to => "#{@user.fullname} <#{@user.email}>",
    mail({
      :to => EMAIL_TO,
      :subject => "Gift purchase complete #{@user.fullname}"
    })
  end

  def notify_receiver(gift)
    @gift           = gift
    @email_title    = "Drinkboard Email Messenger"
    @cart           = @gift.ary_of_shopping_cart_as_hash
    @merchant       = @gift.provider
    @header_text    = "You have Received a Gift"
    @social         = 0
    @web_view_route = "#{TEST_URL}/webview/notify_receiver/#{gift.id}"
    # :to => "#{@gift.receiver_name} <#{@gift.receiver_email}>",
    mail({
      :to => EMAIL_TO,
      :subject => "A Gift has been purchased for You! #{@gift.receiver_name}"
    })
  end

  def notify_giver_order_complete(giver, gift)
    @user           = giver
    @gift           = gift
    @email_title    = "Drinkboard Email Messenger"
    @cart           = @gift.ary_of_shopping_cart_as_hash
    @merchant       = @gift.provider
    @header_text    = "Your Gift Has Been Redeemed"
    @social         = 0
    @web_view_route = "#{TEST_URL}/webview/notify_giver_order_complete/#{gift.id}"
    # :to => "#{@user.fullname} <#{@user.email}>",
    mail({
      :to => EMAIL_TO,
      :subject => "Gift Redeem complete #{@user.fullname}"
    })    
  end

  def notify_giver_created_user(giver, gift)
    @user           = giver
    @gift           = gift
    @email_title    = "Drinkboard Email Messenger"
    @cart           = @gift.ary_of_shopping_cart_as_hash
    @merchant       = @gift.provider
    @header_text    = "Your Gift has been Received"
    @social         = 0
    @web_view_route = "#{TEST_URL}/webview/notify_giver_created_user/#{gift.id}"
    # :to => "#{@user.fullname} <#{@user.email}>",
    mail({
      :to => EMAIL_TO,
      :subject => "Gift to #{@gift.receiver_name} has been received! #{@user.fullname}"
    })    
  end

end

