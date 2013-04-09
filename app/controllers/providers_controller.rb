class ProvidersController < ApplicationController
  before_filter :signed_in_user
  before_filter :admin_user?
  ACTIONS_WITH_HEADERS = [ :help, :explorer, :pos, :menujs, :menu, :edit_photo, :menu_builder, :show, :photos, :edit_info, :edit_bank, :update, :orders, :past_orders, :redeem, :completed, :customers, :staff_profile, :staff ]

  before_filter :populate_locals, only: ACTIONS_WITH_HEADERS

  def index
    @offset = params[:offset].to_i || 0
    @page = @offset
    paginate = 9
    @merchants = Provider.limit(paginate).offset(@offset) 
    if @merchants.count == paginate
      @offset += paginate
    else
      @offset = 0
    end

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
        format.json { head :no_content }
      else
        @partial_to_render = "error"
        @message = human_readable_error_message @provider
        format.html { redirect_to edit_info_merchant_path(@provider), notice: 'Update was unsuccessful' }
        format.js { render 'error' }
        format.json { render json: @provider.errors, status: :unprocessable_entity }
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

  def add_photo
    @provider = Provider.find(params[:id].to_i)
    @obj_to_edit = @provider
    @obj_name = "provider"
    @file_field_name = "photo"
    @obj_width = 600
    @obj_height = 320
    @action = "upload_photo"
  end

  def upload_photo
    @provider = Provider.find(params[:id].to_i)
    @provider.update_attributes(params[:provider])
    redirect_to provider_path(@provider)    
  end

  def brands
    @offset = params[:offset].to_i || 0
    @page = @offset
    @provider = Provider.find(params[:id].to_i)
    paginate = 10
    @brands = Brand.limit(paginate).offset(@offset)
    if @brands.count == paginate
      @offset += paginate 
    else
      @offset = 0
    end
  end

  def building
    @provider = Provider.find(params[:id].to_i)
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
    @provider = Provider.find(params[:id].to_i)
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

  def menu
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

  def staff
    @staff    = @provider.employees
    @nonstaff = @provider.users_not_staff    
  end


    private

      def populate_locals
        @provider       = Provider.find(params[:id].to_i)
        @current_user   = current_user
      end
end
