class EmailJob
  @queue = :email
  
  def self.perform(email_type, user_id, opthash = {})
    case email_type
    when "confirm_email"
      puts "OPT CONFIRM EMAIL"
      @user = User.find(user_id)
      UserMailer.confirm_email(@user).deliver
    
    when "reset_password"
      puts "OPT RESETPASSWORD"
      @user = User.find(user_id)
      UserMailer.reset_password(@user).deliver
    
    when "invite_friend"
      @user = User.find(user_id)
      puts "OPTHASH INVITE FRIEND"
      puts opthash
      puts opthash["email"]
      UserMailer.invite_friend(@user, opthash["email"], opthash["gift_id"]).deliver
    
    when "invite_employee"
      puts "OPTHASH INVITE EMPLOYEE"
      puts opthash
      @user = User.find(user_id)    #Person making the request
      @provider = Provider.find(opthash[:provider_id])
      UserMailer.invite_employee(@user,@provider,opthash["email"]).deliver
    
    when "invoice_giver" 
      puts "OPTHASH INVOICE GIVER"
      @user = User.find(user_id)
      if @user.setting.email_invoice
        @gift = Gift.find(opthash[:gift_id])
        UserMailer.invoice_giver(@user, @gift).deliver
      else
        puts "#{@user.fullname} does not receiver Invoice Giver Email"
      end
    
    when "notify_receiver" 
      puts "OPTHASH NOTIFY RECEIVER"
      email = opthash[:email]
      @gift = Gift.find(opthash[:gift_id])
      send  = true
      if @gift.receiver_id.to_i > 1
        receiver = User.find(receiver_id)
        send     = receiver.setting.email_receiver_new
      end
      UserMailer.notify_receiver(@gift).deliver if send
    
    when "notify_giver_order_complete"
      puts "OPTHASH NOTIFY GIVER ORDER COMPLETE"
      @user = User.find(user_id)
      if @user.setting.email_redeem
        @gift = Gift.find(opthash[:gift_id])
        UserMailer.notify_giver_order_complete(@user, @gift).deliver
      else
        puts "#{@user.fullname} does not receiver Invoice Giver Email"
      end
    
    when "notify_giver_created_user"
      puts "OPTHASH NOTIFY GIVER CREATED USER"
      @user = User.find(user_id)
      @gift = Gift.find(opthash[:gift_id])
      UserMailer.notify_giver_created_user(@user, @gift).deliver
    end 
  end
  
end