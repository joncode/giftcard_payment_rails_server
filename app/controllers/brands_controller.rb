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

    respond_to do |format|
      if @brand.save
        format.html { redirect_to @brand, notice: 'Brand was successfully created.' }
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
