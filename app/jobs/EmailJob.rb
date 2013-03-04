class EmailJob
  @queue = :email
  
  def self.perform(email_type, user_id, opthash = {})
    case email_type
    when "confirm_email"
      @user = User.find(user_id)
      UserMailer.confirm_email(@user).deliver
    when "reset_password"
      puts "OPT RESETPASSWORD"
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
    when "invoice_giver" 
      puts "OPTHASH INVOICE GIVER"
      @user = User.find(user_id)
      @gift = Gift.find(opthash[:gift_id])
      UserMailer.invoice_giver(@user, @gift).deliver
    when "notify_receiver" 
      puts "OPTHASH NOTIFY RECEIVER"
      email = opthash[:email]
      @gift = Gift.find(opthash[:gift_id])
      UserMailer.notify_receiver(@gift).deliver
    when "notify_giver_order_complete"
      puts "OPTHASH NOTIFY GIVER ORDER COMPLETE"
      @user = User.find(user_id)
      @gift = Gift.find(opthash[:gift_id])
      UserMailer.notify_giver_order_complete(@user, @gift).deliver
    when "notify_giver_created_user"
      puts "OPTHASH NOTIFY GIVER CREATED USER"
      @user = User.find(user_id)
      @gift = Gift.find(opthash[:gift_id])
      UserMailer.notify_giver_created_user(@user, @gift).deliver
    end 
  end
  
end