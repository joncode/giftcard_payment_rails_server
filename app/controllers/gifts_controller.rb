class GiftsController < ApplicationController
    before_filter :signed_in_user
    before_filter :admin_user?

    def index
        @gifts = Gift.order("updated_at DESC").page(params[:page]).per_page(25)
    end

end
