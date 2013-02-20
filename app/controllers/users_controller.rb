class UsersController < ApplicationController
  before_filter :signed_in_user, only: [:index, :edit, :update, :destroy, :show] 
  before_filter :correct_user, only: [:edit, :update]
  before_filter :admin_user, only: :destroy

  def update_avatar
    @provider = Provider.find(params[:id])
    current_user.update_attributes(params[:user])
    redirect_to staff_profile_merchant_path(@provider)
  end

  def index
    
    @user = current_user
    @users = (current_user.blank? ? User.all : User.find(:all, :conditions => ["id != ?", current_user.id]))
    @fb_users = []
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
    @user = User.find(params[:id])
    @gifts = Gift.get_user_activity(@user)
    
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
    
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(params[:user])
    
    if @user.save
      sign_in @user
      flash[:notice] = "Welcome to #{PAGE_NAME}!"
      redirect_back_or @user
    else
      render 'new'
    end
  end

  def update
    msg = ""
    puts "#{params}"
    @user = User.find(params[:id])
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
        format.json { head :no_content }
        format.js
      else
        #sign_in @user
        @message = human_readable_error_message @user
        format.html { render action: action, notice: "Update Unsuccessful"}
        format.json { render json: @user.errors, status: :unprocessable_entity }
        format.js { render 'error' }
      end
    end
  end
  
  def crop
    @obj_to_edit = User.find(params[:id])
    @obj_name = "user"
    @action = "update_avatar"
    @file_field_name = "photo"
    @obj_width = 131
    @obj_height = 131
    render "shared/uploader"
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_path, notice: "User Destroyed." }
      format.json { head :no_content }
    end
  end
  
  def following
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.followed_users
    render 'show_follow'
  end
  
  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers
    render 'show_follow'
  end
  
  def servercode
    @user = current_user
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
  
  def reset_password

    if params[:user] && params[:user].has_key?("email")
      email = params[:user]["email"]
      if user = User.find_by_email(email)
        user.update_reset_token
        # UserMailer.reset_password(user).deliver # use this for basic rails mailer
        Resque.enqueue(EmailJob, 'reset_password', user[:id], {})  
      end
    elsif params[:reset_token]
      @user = User.find_by_reset_token(params[:reset_token])
      if Time.now - 1.day <= @user.reset_token_sent_at
        return render 'enter_new_password'
      end
    end
  end
  
  def enter_new_password
    user_params = params[:user]
    if !user_params[:password] || !user_params[:password_confirmation]
      return redirect_to reset_password_users_path
    end
    @message = nil
    if user_params[:password] != user_params[:password_confirmation]
      @message = "Your passwords do not match. Try again."
    else
      user = User.find_by_reset_token(params[:reset_token])
      user.password = user_params[:password]
      user.password_confirmation = user_params[:password_confirmation]
      user.save
      @message = "Password saved successfully."
      sign_in user
      return redirect_to '/home'
    end
  end
  
  private

    
    def correct_user
      @user = User.find(params[:id])
      redirect_to(users_path) unless current_user?(@user)
    end
    
    def admin_user
      redirect_to(users_path) unless current_user.admin?
    end
    
    def sanitize_filename(file_name)
      just_filename = File.basename(file_name)
      just_filename.sub(/[^\w\.\-]/,'_')
    end
end
