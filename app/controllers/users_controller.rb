class UsersController < ApplicationController
  before_filter :signed_in_user , except: [:new, :create]
  before_filter :admin_user? , except: [:new, :create]

  ###########   CRUD METHODS

  def index
    
    @user = current_user
    # @users = (current_user.blank? ? User.all : User.find(:all, :conditions => ["id != ?", current_user.id]))
    @users = User.order("first_name ASC").page(params[:page]).per_page(16)
    # @fb_users = []
    # if @user.facebook_access_token
    #   fb_response = HTTParty.get("https://graph.facebook.com/me/friends?access_token="+@user.facebook_access_token)
    #   if fb_response.code == 200
    #     @fb_users = ActiveSupport::JSON.decode(fb_response.body)["data"]
    #   end
    # end
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  def show    
    @user   = User.find(params[:id].to_i)
    @gifts  = Gift.get_user_activity(@user).page(params[:page]).per_page(6)

    @active = set_active
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  def new  
    sign_out  
    @user  = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  def edit
    
    @user = User.find(params[:id].to_i)
  end

  def create
    @user = User.new(params[:user])
    
    if @user.save
      sign_in @user
      flash[:notice] = "Welcome to #{PAGE_NAME}!"
      redirect_back_or root_path
    else
      flash[:error] = human_readable_error_message(@user).join(' - ')
      render 'new'
    end
  end

  def update
    msg = ""
    puts "#{params}"
    @user = User.find(params[:id].to_i)
    # action = params[:commit] == 'Submit Server Code' ? 'servercode' : 'edit'
    # if action == 'edit'
    #   if !params[:user][:photo].nil? || !params[:user][:photo_cache].empty?
    #     params[:user][:use_photo] = "cw"
    #   end
    # end

    respond_to do |format|
      if @user.update_attributes(params[:user])
        #sign_in @user
        format.html { redirect_to @user, notice: "Update Successful. #{msg}" }
        format.js
      else
        #sign_in @user
        @message = human_readable_error_message @user
        format.html { render action: action, notice: "Update Unsuccessful"}
        format.js { render 'error' }
      end
    end
  end

  def destroy
    @user = User.find(params[:id].to_i)
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_path, notice: "User Destroyed." }
    end
  end

  ###########   SECONDARY CRUD METHODS

    def de_activate
        @user        = User.find(params[:id].to_i) 
        @user.active = @user.active ? false : true

        respond_to do |format|
            if @user.save
                format.html { redirect_to user_path(@user), notice: "User Updated." }
            else
                format.html  { redirect_to user_path(@user), notice: human_readable_error_message(@user) }
            end
        end
    end

    def destroy_gifts
        @user       = User.find(params[:id].to_i)
        total_gifts = Gift.get_user_activity(@user)
        total_gifts.each {|gift| gift.destroy}

        respond_to do |format|
            if Gift.get_user_activity(@user).count == 0
                format.html { redirect_to user_path(@user), notice: "Gifts Destroyed." }
            else
                format.html  { redirect_to user_path(@user), notice: "Error in batch delete gifts" }
            end
        end
    end

    ########    PHOTO SYSTEM METHODS
  
    def crop
        @obj_to_edit = User.find(params[:id])
        @obj_name = "user"
        @action = "update_avatar"
        @file_field_name = "photo"
        @obj_width = 131
        @obj_height = 131
        render "shared/uploader"
    end

    def update_avatar
        @provider = Provider.find(params[:id])
        params[:user][:use_photo] = "cw"
        current_user.update_attributes(params[:user])
        redirect_to staff_profile_merchant_path(@provider)
    end

    ############   SOCIAL CONNECTION METHODS

    def following
        @title = "Following"
        @user = User.find(params[:id].to_i)
        @users = @user.followed_users
        render 'show_follow'
    end

    def followers
        @title = "Followers"
        @user = User.find(params[:id].to_i)
        @users = @user.followers
        render 'show_follow'
    end

    def change_public_status
        newStatus = (params[:newStatus] == "true" ? true : false)
        if (current_user[:is_public] && !newStatus) || (!current_user[:is_public] && newStatus)
            current_user[:is_public] = newStatus
            current_user.save
            Location.create(:user_id => current_user[:id], :vendor_type => (newStatus ? "activate" : "deactivate"), :latitude => params[:lat], :longitude => params[:lng])    #Empty location update juust so we know when the user turns on.
        end
        render :json => {success: true}
    end
  
    #############   UTILITY METHODS

  def servercode
    @user = current_user
  end
  
  def confirm_email
    request.format = :email
    if @user = User.find_by_email(params[:email])
      if @user.id == params[:user].to_i
        confirm   = "1" + @user.confirm[1]
        @user.update_attribute(:confirm, confirm)
        action  = :email_confirmed
      else
        action  = :error
      end
    else
      action   = :error
    end

    respond_to do |format|
        format.email { redirect_to :controller => :invite, :action => action } 
    end
  end
  
  # def reset_password
  #   puts "IN RESET PASSWORD"
  #   if params[:user] && params[:user].has_key?("email")
  #     email = params[:user]["email"]
  #     if user = User.find_by_email(email)
  #       user.update_reset_token
  #       # UserMailer.reset_password(user).deliver # use this for basic rails mailer
  #       Resque.enqueue(EmailJob, 'reset_password', user[:id], {})  
  #     end
  #   elsif params[:reset_token]
  #     @user = User.find_by_reset_token(params[:reset_token])
  #     if Time.now - 1.day <= @user.reset_token_sent_at
  #       return render 'enter_new_password'
  #     end
  #   end
  # end
  
  # def enter_new_password
  #   user_params = params[:user]
  #   if !user_params[:password] || !user_params[:password_confirmation]
  #     return redirect_to reset_password_users_path
  #   end
  #   @message = nil
  #   if user_params[:password] != user_params[:password_confirmation]
  #     @message = "Your passwords do not match. Try again."
  #   else
  #     user = User.find_by_reset_token(params[:reset_token])
  #     user.password = user_params[:password]
  #     user.password_confirmation = user_params[:password_confirmation]
  #     user.save
  #     @message = "Password saved successfully."
  #     sign_in user
  #     return redirect_to '/home'
  #   end
  # end
  
  private

    def set_active
      @user.active ?  ["User is Active","De-Activate"] : ["User is De-Activated","Activate"]
    end

end
