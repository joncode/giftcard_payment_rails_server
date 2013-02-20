class UserMailer < ActionMailer::Base

  default :css => :email, :from => "noreplydrinkboard@gmail.com"
  
  def reset_password(user)
    @user = user
    puts "We are in reset password in usermailer for #{user.username}"
    mail({
      :to => "#{@user.username} <#{@user.email}>",
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
  
end

