class ProvidersController < ApplicationController
  before_filter :signed_in_user
  before_filter :admin_user?
  before_filter :populate_locals, except: [:index, :new]

  #############  CRUD methods

  def index
    @merchants = Provider.order("updated_at DESC").page(params[:page]).per_page(8) 

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @merchants }
    end
  end

  def show
    @provider = Provider.find(params[:id].to_i)
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @provider }
    end
  end

  def new
    @provider = Provider.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @provider }
    end
  end

  def edit
    @provider = Provider.find(params[:id].to_i)
    @go_live  = set_go_live
    @active   = set_active
  end

  def create
    super_user  = current_user
    @provider   = Provider.new(params[:provider])

    respond_to do |format|
      if @provider.save
        Employee.create!(provider_id: @provider.id, user_id: super_user.id, clearance: 'super')
        format.html { redirect_to provider_path(@provider), notice: 'Merchant was successfully created.' }
        format.js 
        format.json { render json: merchant_path(@provider), status: :created, location: @provider }
      else
        format.html { render action: "new" }
        format.js
        format.json { render json: @provider.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @provider = Provider.find(params[:id].to_i)

    respond_to do |format|
      if @provider.update_attributes(params[:provider])
        @partial_to_render = "success"
        format.html { redirect_to provider_path(@provider), notice: 'Merchant was successfully updated.' }
        # format.html { redirect_to merchant_path(@provider), notice: 'Provider was successfully updated.' }
        format.js 
      else
        @partial_to_render = "error"
        @message = human_readable_error_message @provider
        puts @message
        @go_live = set_go_live
        @active = set_active
        format.html { render action: "edit", notice: 'Update was unsuccessful' }
        format.js { render 'error' }
      end
    end
  end

  def destroy
    @provider = Provider.find(params[:id].to_i)
    @provider.destroy

    respond_to do |format|
      format.html { redirect_to providers_url }
      format.json { head :no_content }
    end
  end

  ###########  STATUS METHODS

  def coming_soon
    @provider.sd_location_id = @provider.live_bool ? nil : 1
    @provider.save
    respond_to do |format|
      format.html { redirect_to action: 'edit'}
    end

  end

  def de_activate
    @provider.active = @provider.active ? false : true
    @provider.save
    respond_to do |format|
      format.html { redirect_to action: 'edit'}
    end
  end

  ######### PHOTO METHODS

  def add_photo
    @provider     = Provider.find(params[:id].to_i)
    @obj_to_edit  = @provider
    @obj_name     = "provider"
    @file_field_name = "photo"
    @obj_width    = 600
    @obj_height   = 320
    @action       = "upload_photo"
  end

  def upload_photo
    @provider = Provider.find(params[:id].to_i)
    if @provider.update_attributes(params[:provider])
      redirect_to provider_path(@provider) 
    else
      @partial_to_render = "error"
        @message = human_readable_error_message @provider
      redirect_to action: "add_photo"
    end   
  end

  ########## BRAND ASSOCIATION METHODS

  def brands
    @brands = Brand.order("name ASC").page(params[:page]).per_page(8)

  end

  def building
    brand = Brand.find(params[:brand].to_i)
    if @provider.building_id != brand.id
      @provider.building_id = brand.id
    else
      @provider.building_id = nil
    end
    @provider.save
    
    respond_to do |format|
      format.html { redirect_to brands_provider_path(@provider, :offset => params[:offset])}
    end
  end

  def brand
    brand = Brand.find(params[:brand].to_i)
    if @provider.brand_id != brand.id
      @provider.brand_id = brand.id 
    else
      @provider.brand_id = nil
    end
    @provider.save

    respond_to do |format|
      format.html { redirect_to brands_provider_path(@provider, :offset => params[:offset])}
    end    
  end

 ####### EMPLOYEE METHODS

  def staff(email_sent=nil)
      @people     = Employee.where(provider_id: @provider.id, active: true ).page(params[:page]).per_page(8)
      @email_sent = email_sent 
  end

  def members
      @people = User.page(params[:page]).per_page(8)
      render 'staff'
  end

  def add_member
      user = User.find(params[:user_id].to_i)
      if user.is_employee?(@provider)
        #success
        employee = Employee.where(provider_id: @provider.id, user_id: user.id).pop
        employee.update_attribute(:active, true)
      else
        # fail
        Employee.create(user_id: user.id, provider_id: @provider.id)
      end 
      redirect_to staff_provider_path(@provider)
  end

  def invite_employee
    respond_to do |format|
      if request.get?
        #Show the page.
        format.html { redirect_to action: :add_employee }
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

        format.html { redirect_to staff_provider_path(@provider) }
      end
    end
  end

  def remove_employee
      if params[:eid]
        employee = Employee.find(params[:eid].to_i)
        employee.update_attribute(:active, false)
      end
      redirect_to staff_provider_path(@provider)
  end

  ############### MENU BUILDER METHODS

  def menu
    @menu_array     = Menu.get_menu_array_for_builder @provider 

  end

  def menu_item
    if params[:menu_item].to_i == 0
      @menu_item = Menu.new
      @menu_item.section = params[:section]
      @menu_item.provider_id = @provider.id
    else
      @menu_item = Menu.find(params[:menu_item].to_i)
    end

  end

  def upload_menu
    @menu_array     = Menu.get_menu_array_for_builder @provider
    respond_to do |format|
      if MenuString.compile_menu_to_menu_string(@provider.id)
        # update the menu string to show the menustring is up to date 
        # render success
          @message = "Merchant Menu on App is Updated and Now Live"
          format.html { redirect_to action: :menu, notice: @message } 
      else
        # render error
        @message = human_readable_error_message menu_string
        format.html { render action: :menu, notice: @message }
      end
    end    
  end

  def remove_menu_item
    @menu_item = Menu.find(params[:menu_item].to_i)

    respond_to do |format|
      if @menu_item.update_attributes({active: false})
        @message = "#{@menu_item.item_name} De-Activated"
        format.html { redirect_to action: :menu, notice: @message } 
      else
        @message = human_readable_error_message @menu_item
        format.html { render action: :menu, notice: @message }
      end
    end
  end

  private

    def set_go_live
      @provider.live_bool ?  ["LIVE","Make Coming Soon"] : ["Coming Soon","Go LIVE"]
    end

    def set_active
      @provider.active ?  ["Merchant is Active","De-Activate"] : ["Merchant is De-Activated","Activate"]

    end

  ############ JS Methods - REMOVE CORRESPONDING VIEWS WHEN DELETING

  # def update_item
  #   puts "update item => #{params}"
  #   if params[:item_id]
  #     @menu = Menu.find(params[:item_id].to_i)
  #   else
  #     @menu = Menu.new
  #     @menu.provider_id = params[:id].to_i
  #     @menu.section = params[:section]
  #   end
  #   @menu.item_name = params[:item_name]
  #   @menu.description = params[:description]
  #   @menu.price = params[:price]
  #   respond_to do |format|
  #     if @menu.save
  #       @menu.provider.update_attribute(:menu_is_live, false)
  #       # response = {"success" => "Menu Item Saved!"}
  #       @message = "#{@menu.item_name} Updated"
  #       @go_live = "compile_menu_button"
  #       format.js { render 'compile_menu'}
  #     else
  #       @message = human_readable_error_message @menu
  #       format.js { render 'compile_error'}
  #     end
  #   end
  # end

  # def delete_item
  #     puts "delete item => #{params}"
  #     item = Menu.find(params[:item_id].to_i)

  #     respond_to do |format|
  #       if item.update_attributes({active: false})
  #         item.provider.update_attribute(:menu_is_live, false)
  #         # response = {"success" => "Menu Item Deactivated"}
  #         @message = "#{item.item_name} De-Activated"
  #         @go_live = "compile_menu_button"
  #         format.js { render 'compile_menu'}
  #       else
  #         @message = human_readable_error_message @menu
  #         format.js { render 'compile_error'}
  #       end
  #     end
  # end

  # def compile_menu
  #   @provider = Provider.find(params[:id].to_i)
    
  #   respond_to do |format|
  #     if MenuString.compile_menu_to_menu_string(@provider.id)
  #       # update the menu string to show the menustring is up to date 
  #       # render success
  #         @message = "Merchant Menu on App is Updated and Now Live"
  #         @go_live = "live_menu_notice"
  #         format.js 
  #     else
  #       # render error
  #       @message = human_readable_error_message menu_string
  #       format.js { render 'compile_error'}
  #     end
  #   end
  # end

end
