class Web::V3::MenuItemsController < MetalCorsController

    before_action :authentication_no_token

    def show
        id_or_url_slug = params[:id]
        if id_or_url_slug.gsub(/[0-9]/, '') == 0
            menu_item = MenuItem.find id_or_url_slug
        else
            menu_item = MenuItem.find_by token: id_or_url_slug
        end
        if menu_item.kind_of?(MenuItem)
            success menu_item.list_serialize
        else
            fail_web({ err: "INVALID_INPUT", msg: "Menu Item could not be found"})
        end

        respond
    end

end
