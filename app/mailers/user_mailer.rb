class UserMailer < ActionMailer::Base
#  default from: "from@example.com"
  

  default :from => "noreplydrinkboard@gmail.com"
  
  def reset_password(user)
    @user = user
    mail({:to => "#{user.username} <#{user.email}>", 
          :subject => "drinkboard: password reset request"})
  end
    
  def invite_friend(user, friends_name, friends_email)
    @user = user
    @friend = {:name => friends_name, :email => friends_email}
    mail({
      :to => "#{@friend[:name]} <#{@friend[:email]}>",
      :subject => "Your friend #{user.first_name} invited you to drinkboard."
    })
  end
  
end

