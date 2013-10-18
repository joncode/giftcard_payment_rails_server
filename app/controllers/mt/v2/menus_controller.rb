class Mt::V2::MenusController < JsonController

    def update
        menu_hsh = params["data"]
        menu_str = MenuString.find_by_provider_id(@provider.id)
        if menu_str.update_attributes(menu: menu_hsh)
            success   "Menu Update Successful"
        else
            fail      menu_str
        end

        respond
    end

end