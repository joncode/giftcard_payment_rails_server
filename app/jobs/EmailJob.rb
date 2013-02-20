class EmailJob
  @queue = :email
  
  def self.perform(email_type, user_id, opthash = {})
    case email_type
    when "reset_password"
      @user = User.find(user_id)
      UserMailer.reset_password(@user).deliver
    when "invite_friend"
      @user = User.find(user_id)
      puts "OPTHASH"
      puts opthash
      puts opthash["email"]
      UserMailer.invite_friend(@user, opthash["email"], opthash["gift_id"]).deliver
    when "invite_employee"
      puts "OPTHASH EMPLOYEE"
      puts opthash
      puts opthash[:provider_id]
      puts opthash[:email]
      @user = User.find(user_id)    #Person making the request
      @provider = Provider.find(opthash[:provider_id])
      UserMailer.invite_employee(@user,@provider,opthash["email"]).deliver
    when "notify_giver" 
      puts "OPTHASH NOTIFY GIVER"
      @user = User.find(user_id)
      @gift = Gift.find(opthash[:gift_id])
      UserMailer.notify_giver(@user, @gift).deliver
    when "notify_receiver" 
      puts "OPTHASH NOTIFY RECEIVER"
      email = opthash[:email]
      @gift = Gift.find(opthash[:gift_id])
      UserMailer.notify_receiver(@gift).deliver
    when "notify_giver_completion"
      puts "OPTHASH NOTIFY GIVER COMPLETION"
      @user = User.find(user_id)
      @gift = Gift.find(opthash[:gift_id])
      UserMailer.notify_giver_completion(@user, @gift).deliver
    when "alert_giver"
      puts "OPTHASH ALERT GIVER TO COLLECTED GIFT"
      @user = User.find(user_id)
      @gift = Gift.find(opthash[:gift_id])
      UserMailer.alert_giver(@user, @gift).deliver
    end 
  end
  
end