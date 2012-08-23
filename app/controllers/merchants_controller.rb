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














end
