class MerchantsController < ApplicationController
  
  # test methods
  def help
    @provider       = Provider.find(params[:id])
    @current_user   = current_user
  end

  def explorer
    @provider       = Provider.find(params[:id])
    @current_user   = current_user  
    @explorer = params["name"].split(".html")[0]
  end

  def menujs
    @provider       = Provider.find(params[:id])
    @current_user   = current_user
    @menu_array     = Menu.get_menu_array_for_builder @provider
    column = 1
    @left = []
    @right = []
    @menu_array.each do |m|
      if column == 1
        @left << m
        column = 2
      else
        @right << m 
        column = 1
      end
    end
    @menu_array = @menu_array.to_json
  end

  # end test methods

  def update_item
    @menu = Menu.find(params[:item_id])
    @menu.item_name = params[:item_name]
    @menu.description = params[:description]
    @menu.price = params[:price]
    respond_to do |format|
      if @menu.save
        response = {"success" => "Menu Item Saved!"}
      else
        response = {"error" => @menu.errors.messages}
      end
      #format.json {redirect_to menu_merchant_path(params[:id])}
      format.json { render json: response}
    end
  end

  def index
    @providers = current_user.providers    

    respond_to do |format|
      if @providers.count == 1
        format.html { redirect_to merchant_path(@providers.pop) }
      else
        format.html
      end
    end
  end

  def menu
    @provider       = Provider.find(params[:id])
    @current_user   = current_user
    @menu_array     = Menu.get_menu_array_for_builder @provider
    column = 1
    @left = []
    @right = []
    @menu_array.each do |m|
      if column == 1
        @left << m
        column = 2
      else
        @right << m 
        column = 1
      end
    end
  end

  def show
    @provider = Provider.find(params[:id])
    @current_user = current_user
    @menu = create_menu_from_items(@provider)
    @gifts = Gift.get_activity_at_provider(@provider)
  end

  def photos
    @provider = Provider.find(params[:id])
    #@current_user = current_user
    redirect_to  edit_photo_merchant_path(@provider)
  end

  def edit_photo
    @provider = Provider.find(params[:id])
    @current_user = current_user

    @obj_to_edit = @provider
    @obj_name = "provider"
    @file_field_name = "photo"
    @obj_width = 600
    @obj_height = 320
    @action = "update_photos"
  end

  def update_photos
    @provider = Provider.find(params[:id])
    @provider.update_attributes(params[:provider])
    redirect_to photos_merchant_path(@provider)
  end

  def edit_info
    @provider = Provider.find(params[:id])
    @current_user = current_user
  end

  def edit_bank
    @provider = Provider.find(params[:id])
    @current_user = current_user
  end

  def update
    @provider = Provider.find(params[:id])

    respond_to do |format|
      if @provider.update_attributes(params[:provider])
        format.html { redirect_to @provider, notice: 'Provider was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @provider.errors, status: :unprocessable_entity }
      end
    end    
  end

  def orders
    @provider = Provider.find(params[:id])
    @gifts = Gift.get_all_orders(@provider)

    respond_to do |format|
      if @gifts.nil?
        format.html 
      else
        format.html # index.html.erb
        format.js
        format.json { render json: @gifts }
      end
    end
  end

  def past_orders
    @provider = Provider.find(params[:id])
    @gifts = Gift.get_history_provider(@provider)
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @gifts }
    end
  end

  def redeem
    @provider = Provider.find(params[:id])
    @gift = Gift.find(params[:gift_id])
    @redeem = Redeem.find_by_gift_id(@gift)
    #@provider = @gift.provider
    @employee = Employee.where(user_id: current_user.id, provider_id: @provider.id)[0]
    
    if @redeem
      @order = Order.new(redeem_id: @redeem.id, gift_id: @gift.id, provider_id: @provider.id, employee_id: @employee.id)
    else
      # no redeem = no order possible
      @order = Order.new
    end


    respond_to do |format|
      format.html # show.html.erb
      format.js { render 'order'}
      format.json { render json: @redeem }
    end
  end
  
  def completed
    @provider = Provider.find(params[:id])
    @gift = Gift.find(params[:gift_id])
    @giver = @gift.giver
    @receiver = @gift.receiver
    @order = @gift.order
    if @order.server_id
      @server = User.find(@order.server_id) 
    else
      @server = User.new(first_name: "missing", last_name: "person")
    end
    respond_to do |format|
      format.html # detail.html.erb
      format.js
      format.json { render json: @gift }
    end
  end

  def customers
    @provider = Provider.find(params[:id])    
    @user     = current_user
    @users    = (current_user.blank? ? User.all : User.find(:all, :conditions => ["id != ?", current_user.id]))
    # list customers on the screen with most recent activity first
        # most drinks ordered
        # most money spent
    # check all the gifts , get the giver and receiver user ids
    # assign those ids to the gift.updated_at field 
    # make a uniq array of all user ids
    # remove employees from that list 
    # list those customers on the screen by gift.updated_at
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  def staff
    @provider = Provider.find(params[:id])
    
    @staff    = @provider.users
  end

  def staff_profile
    @provider = Provider.find(params[:id])
    @user = current_user
  end

  def add_employee
    return redirect_to "/" if !params[:join_token] && !params[:email]

    provider = Provider.find_by_join_token(params[:join_token])
    return redirect_to "/" if !provider
    
    user = User.find_by_email(params[:email])
    return redirect_to "/" if !user
    
    #Otherwise, put the user in the employees hash.
    provider.employees << user
    flash[:notice] = "You successfully joined #{provider.name}."
    redirect_to "/"
  end

  def invite_employee
    @provider = Provider.find(params[:id])
    if request.get?
      #Show the page.
    elsif request.post?
      #Find the user, etc
      if !params[:email]
        return flash[:notice] = "You must enter in a user email."
      end
      potential_employee = User.find_by_email(params[:email])
      if !potential_employee
        #If the user doesn't exist in the database
      else
        #The user does exist in the database        
      end
      #For now, we handle either situation the same
      Resque.enqueue(EmailJob, 'invite_employee', current_user.id, {:provider_id => @provider.id, :email => params[:email]})
    end
  end
  
  def remove_employee
    #REMOVE THIS RETURN STATEMENT TO HAVE THE LINK FUNCTION PROPERLY.
    return redirect_to "/merchants/#{params[:id]}/staff"
    if params[:eid]
      provider = Provider.find(params[:id])
      provider.employees.each do |employee|
        if ""+employee.user_id == ""+params[:id]
          provider.employees.delete(employee)
          provider.save
          break
        end
      end
    end
    redirect_to "/merchants/#{params[:id]}/staff"
  end

end
