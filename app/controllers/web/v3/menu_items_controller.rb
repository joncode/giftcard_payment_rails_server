class Web::V3::MenuItemsController < MetalCorsController

    before_action :authentication_no_token

    def show
        id_or_url_slug = params[:id]
        id = id_or_url_slug
        if id_or_url_slug.gsub(/[0-9]/, '').length != 0
            id_or_url_slug.gsub!('_', '-')
            id = id_or_url_slug.split('-').first
        end
        menu_item = MenuItem.find id
        if menu_item.kind_of?(MenuItem)
            success menu_item.list_serialize
        else
            fail_web({ err: "INVALID_INPUT", msg: "Menu Item could not be found"})
        end

        respond
    end

    def book
        book = Book.find_with_token(params[:id])

        if book.kind_of?(Book)
            success book.list_serialize
        else
            fail_web({ err: "INVALID_INPUT", msg: "Menu Item could not be found"})
        end

        respond
    end

end
