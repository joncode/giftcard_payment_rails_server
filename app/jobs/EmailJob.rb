class EmailJob
  @queue = :email
  
  def self.perform(email_type, user_id, opthash = {})
    if email_type == "invite_friend"
      @user = User.find(user_id)
      UserMailer.invite_friend(@user, opthash[:name], opthash[:email])
    elsif email_type == "reset_password"
      @user = User.find(user_id)
      UserMailer.reset_password(@user)
    elsif email_type == "invite_employee"
      #Do this
    end
  end
  
end