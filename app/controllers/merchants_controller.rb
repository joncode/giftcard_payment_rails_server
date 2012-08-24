class MerchantsController < ApplicationController
  
  def index
    providers = current_user.provider_id

    respond_to do |format|
      if providers.count == 1
        provider = Provider.find(providers).pop
        format.html { redirect_to merchant_path(provider) }
      else
        @providers = Provider.find(providers)
        format.html
      end
    end
  end

  def show
    @provider = Provider.find(params[:id])
    @menu = create_menu_from_items(@provider)
    @gifts = Gift.get_activity_at_provider(@provider)
  end

  def redeems
    @provider = Provider.find(params[:id])
    @gifts = Gift.get_provider(@provider)
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @gifts }
    end
  end

  def past_redeems
    @provider = Provider.find(params[:id])
    @gifts = Gift.get_history_provider(@provider)
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @gifts }
    end
  end

  def detail
    @gift = Gift.find(params[:id])
    @giver = User.find(@gift.giver_id)
    @receiver = User.find(@gift.receiver_id)
    @provider = @gift.provider
    
    respond_to do |format|
      format.html # detail.html.erb
      format.json { render json: @gift }
    end
  end

  def redeem
    @gift = Gift.find(params[:id])
    @redeem = Redeem.find_by_gift_id(@gift)
    @provider = @gift.provider


    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @redeem }
    end
  end

  def customers
    @provider = Provider.find(params[:id])    
    @user  = current_user
    @users = (current_user.blank? ? User.all : User.find(:all, :conditions => ["id != ?", current_user.id]))
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




end
