class EmailJob
  @queue = :email
  
  def self.perform(email_type, user_id, opthash = {})
    if email_type == "reset_password"
      @user = User.find(user_id)
      UserMailer.reset_password(@user).deliver
    elsif email_type == "invite_friend"
      @user = User.find(user_id)
      puts "OPTHASH"
      puts opthash
      puts opthash["email"]
      UserMailer.invite_friend(@user, opthash["email"], opthash["gift_id"]).deliver
    elsif email_type == "invite_employee"
      puts "OPTHASH EMPLOYEE"
      puts opthash
      puts opthash["provider_id"]
      puts opthash["email"]
      @user = User.find(user_id)    #Person making the request
      @provider = Provider.find(opthash["provider_id"])
      UserMailer.invite_employee(@user,@provider,opthash["email"]).deliver
    end
  end
  
end