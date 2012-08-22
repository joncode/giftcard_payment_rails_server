class GiftsController < ApplicationController

  def index
    @user = current_user
    @gifts = Gift.get_gifts(@user)
    # ActiveRecord::Base.logger = Logger.new("in method")
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @gifts }
    end
  end
  
  def buy
    @user = current_user
    @gifts = Gift.get_buy_history(@user)
    
    respond_to do |format|
      format.html 
      format.json { render json: @gifts }
    end
  end
  
  def activity
    @user = current_user
    @gifts = Gift.get_activity
    
    respond_to do |format|
      format.html 
      format.json { render json: @gifts }
    end
  end

  def show
    @gift = Gift.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @gift }
    end
  end

  def new
    @gift = Gift.new
    @users = User.all
    @providers = Provider.all

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @gift }
    end
  end
  
  def browse
    # @gift = Gift.new
    @users = User.all
    @providers = Provider.all

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @gift }
    end
  end
  
  def browse_with_contact
    @user = User.find(params[:id])
    @providers = Provider.all
  end
  
  def browse_with_location
    @provider = Provider.find(params[:id])
    @users = User.all    
  end
  
  def choose_from_menu
    @provider = Provider.find(params[:provider_id])
    @receiver = User.find(params[:user_id])
    @menu = @provider.menu_string.data
    
  end

  def edit
    @gift = Gift.find(params[:id])
  end

  def create
    @gift = Gift.new(params[:gift])

    respond_to do |format|
      if @gift.save
        format.html { redirect_to @gift, notice: 'Gift was successfully created.' }
        format.json { render json: @gift, status: :created, location: @gift }
      else
        format.html { render action: "new" }
        format.json { render json: @gift.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @gift = Gift.find(params[:id])

    respond_to do |format|
      if @gift.update_attributes(params[:gift])
        format.html { redirect_to @gift, notice: 'Gift was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @gift.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @gift = Gift.find(params[:id])
    @gift.destroy

    respond_to do |format|
      format.html { redirect_to gifts_url }
      format.json { head :no_content }
    end
  end
end
