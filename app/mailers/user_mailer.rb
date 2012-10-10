class UserMailer < ActionMailer::Base
  default from: "from@example.com"

  def emailheader(user,subj)
    return {:to => "#{user.first_name} #{user.last_name} <#{user.email}>", 
            :subject => subj}
  end
  
  def reset_password(user)
    @user = user
    mail(emailheader(user,"drinkboard: password reset request"))
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

