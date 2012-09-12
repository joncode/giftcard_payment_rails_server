class ApplicationController < ActionController::Base
  
  helper :all
  protect_from_forgery 
  include SessionsHelper
  
  before_filter :prepare_for_mobile

  private
  
    def mobile_device?
      if session[:mobile]
        session[:mobile] == "1"
      else
        if request.user_agent =~ /Mobile|webOS/
          request.user_agent =~ /iPad|tablet|GT-P1000/ ? false : true
        else
          false
        end
      end
    end

    helper_method :mobile_device?
    
    def prepare_for_mobile
      session[:mobile] = params[:mobile] if params[:mobile]
      #  request.format   = :mobile if mobile_device?
    end

    def create_menu_from_items(provider)     
      menu_bulk = Menu.where(provider_id: provider.id)
      items = []
      menu_bulk.each do |item|
         indi = Item.find(item.item_id)
         price = item.price
         item_array = [indi, price]
         items << item_array  
      end
      return items
    end
  
end
