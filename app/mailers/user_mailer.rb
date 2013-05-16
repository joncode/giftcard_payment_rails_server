class UserMailer < ActionMailer::Base

  prod      = "no-reply@drinkboard.com"
  # EMAIL_TO  = "noreplydrinkboard@gmail.com"
  default :css => 'email/email', :from => prod

  def confirm_email(user)
      #  you've just joined the app , confirm your email
    @user           = user
    @header_text    = "Confirm Your Email Address"
    @email_title    = "Drinkboard Email Messenger"
    @web_view_route = "#{TEST_URL}/webview/confirm_email/#{user.id}"
    @social         = 0
    mail({
      :to => "#{@user.fullname} <#{whitelist_user(@user)}>",
      :subject => "Drinkboard: confirm your email #{@user.fullname}"
    })
  end

  def reset_password(user)
    @user           = user
    @header_text    = ""
    @social         = 0
    @email_title    = "Drinkboard Email Messenger"
    @web_view_route = "#{TEST_URL}/webview/reset_password/#{user.id}"
    puts "reset_password -UserMailer-  for #{user.username}"
    mail({
      :to => "#{@user.fullname} <#{whitelist_user(@user)}>",
      :subject => "Drinkboard: password reset request #{@user.fullname}"
    })
  end

  def invite_friend(user, friends_email, gift_id)
    @user = user
    @friends_email = friends_email

    @gift_id = gift_id
    mail({
      :to => "#{whitelist_email(@friends_email)}",
      :subject => "Your friend #{@user.first_name} invited you to drinkboard. #{@friends_email}"
    })
  end

  def invite_employee(user,provider,employee_email, web_route)
    @user = user
    @provider = provider
    @web_view_route = web_route
    puts "INVITE EMPLOYEE via route = #{@web_view_route}"
    mail({
      :to => "#{whitelist_email(employee_email)}",
      :subject => "Drinkboard Merchant Employee Request #{employee_email}"
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
    mail({
      :to => "#{@user.fullname} <#{whitelist_user(@user)}>",
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
    mail({
      :to => "#{@gift.receiver_name} <#{whitelist_email(@gift.receiver_email)}>",
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
    mail({
      :to => "#{@user.fullname} <#{whitelist_user(@user)}>",
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
    mail({
      :to => "#{@user.fullname} <#{whitelist_user(@user)}>",
      :subject => "Gift to #{@gift.receiver_name} has been received! #{@user.fullname}"
    })
  end

  private

    def whitelist_email(email)
            # if email is on blacklist then send email to noreplydrinkboard@gmail.com
            # blacklist is
        bad_emails = ["test@test.com", "jp@jp.com", "jb@jb.com", "gj@gj.com", "fl@fl.com", "adam@adam.com", "rs@rs.com","kk@gmail.com", "bitmover1@gmail.com", "app@gmail.com", "spnoge@bob.com", "adam@gmail.com", "gifter@sos.me", "taylor@gmail.com"]
        if bad_emails.include?(email)
            email = "noreplydrinkboard@gmail.com"
        else
            email = email
        end
        return email
    end

    def whitelist_user(user)
        # if user.email is on blacklist then send email to noreplydrinkboard@gmail.com
        return whitelist_email(user.email)
    end

end

