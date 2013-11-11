class Mdot::V2::ProvidersController < JsonController
    before_filter :authenticate_customer

    def menu
        menu = MenuString.get_menu_v2_for_provider(params[:id])
        if menu
            success(menu)
        else
            not_found
            return nil
        end
        respond
    end

end