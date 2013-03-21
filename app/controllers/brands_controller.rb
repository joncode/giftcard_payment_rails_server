class BrandsController < ApplicationController
  before_filter :signed_in_user
  before_filter :admin_user?

  def index
    @brands = Brand.all

    respond_to do |format|
      if @brands.count > 0
        format.html # index.html.erb
        format.json { render json: @brands }
      else
        format.html {redirect_to new_brand_path }
      end
    end
  end

  def merchants
    @offset = params[:offset].to_i || 0
    @page = @offset
    @brand = Brand.find(params[:id].to_i)
    paginate = 10
    @merchants = Provider.limit(paginate).offset(@offset)
    if @merchants.count == paginate
      @offset += paginate 
    else
      @offset = 0
    end
  end

  def building_merchant
    @brand = Brand.find(params[:id].to_i)
    merchant = Provider.find(params[:merchant].to_i)
    if merchant.building_id != @brand.id
      merchant.building_id = @brand.id
    else
      merchant.building_id = nil
    end
    merchant.save
    
    respond_to do |format|
      format.html { redirect_to merchants_brand_path(@brand, :offset => params[:offset])}
    end
  end

  def brand_merchant
    @brand = Brand.find(params[:id].to_i)
    merchant = Provider.find(params[:merchant].to_i)
    if merchant.brand_id != @brand.id
      merchant.brand_id = @brand.id
    else
      merchant.brand_id = nil
    end
    merchant.save

    respond_to do |format|
      format.html { redirect_to merchants_brand_path(@brand, :offset => params[:offset])}
    end    
  end

  def add_photo
    @brand = Brand.find(params[:id].to_i)
    @obj_to_edit = @brand
    @obj_name = "brand"
    @file_field_name = "banner"
    @obj_width = 600
    @obj_height = 320
    @action = "upload_photo"
  end

  def upload_photo
    @brand = Brand.find(params[:id].to_i)
    @brand.update_attributes(params[:brand])
    redirect_to merchants_brand_path(@brand)    
  end

  def show
    @brand = Brand.find(params[:id].to_i)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @brand }
    end
  end

  def new
    @brand = Brand.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @brand }
    end
  end

  def edit
    @brand = Brand.find(params[:id].to_i)
  end

  def create
    @brand = Brand.new(params[:brand])
    @current_user   = current_user
    @brand.user_id = @current_user.id

    respond_to do |format|
      if @brand.save
        format.html { redirect_to add_photo_brand_path(@brand), notice: 'Brand was successfully created.' }
        format.json { render json: @brand, status: :created, location: @brand }
      else
        format.html { render action: "new" }
        format.json { render json: @brand.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @brand = Brand.find(params[:id].to_i)

    respond_to do |format|
      if @brand.update_attributes(params[:brand])
        format.html { redirect_to @brand, notice: 'Brand was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @brand.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @brand = Brand.find(params[:id].to_i)
    @brand.destroy

    respond_to do |format|
      format.html { redirect_to brands_url }
      format.json { head :no_content }
    end
  end
end
