class UserMailer < ActionMailer::Base

  default :css => :email, :from => "noreplydrinkboard@gmail.com"
  
  def reset_password(user)
    @user = user
    puts "We are in reset password in usermailer for #{user.username}"
    mail({
      :to => "#{@user.fullname} <#{@user.email}>",
      :subject => "drinkboard: password reset request"
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

  def notify_giver(giver, gift)
    @user = giver
    @gift = gift
    mail({
      :to => "#{@user.fullname} <#{@user.email}>",
      :subject => "Gift purchase complete"
    })
  end

  def notify_receiver(gift)
    @gift  = gift
    mail({
      :to => "#{@gift.receiver_name} <#{@gift.receiver_email}>",
      :subject => "A Gift has been purchased for You!"
    })
  end

  def notify_giver_completion(giver, gift)
    @user = giver
    @gift = gift
    mail({
      :to => "#{@user.fullname} <#{@user.email}>",
      :subject => "Gift Redeem complete"
    })    
  end

  def alert_giver(giver, gift)
    @user = giver
    @gift = gift
    mail({
      :to => "#{@user.fullname} <#{@user.email}>",
      :subject => "Gift to #{@gift.receiver_name} has been received!"
    })    
  end

end

