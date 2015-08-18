class Mt::V2::MerchantsController < JsonController
    before_action :authenticate_merchant_tools, except: [:create, :reconcile_merchants]
    before_action :authenticate_general_token,  only:   [:create, :reconcile_merchants]
    rescue_from JSON::ParserError, :with => :bad_request

    def create
        return nil  if data_not_hash?

        hsh = merchant_params
        menu_string = hsh.delete('menu')

        merchant     = Merchant.new hsh
        if merchant.save
            menu = Menu.new(json: menu_string)
            if menu.save
                merchant.update(menu_id: menu.id)
                success merchant.id
            else
                success "Menu was not saved"
            end
        else
            fail    merchant.errors.messages
        end
        respond
    end

    def update
        return nil  if data_not_hash?

        if @merchant.update(merchant_params)
            success   "Merchant Update Successful"
        else
            fail      @merchant
        end
        respond
    end

    def menu
        menu_hsh = params["data"]
        menu = @merchant.menu

        menu_data = ""
        begin
            menu_data = JSON.parse(menu_hsh)
        rescue
            # do nothing
        end

        if !menu_data.kind_of?(Array)
            fail       "Data Not Menu"
        elsif menu.update(json: menu_data)
            success   "Menu Update Successful"
        else
            fail      menu.errors.messages
        end

        respond
    end

    def reconcile

    end

private

    def merchant_params

        allowed = ["menu", "city_id", "rate", "r_sys", "menu_id", "latitude", "longitude", "name", "zinger", "description", "address", "city", "state", "zip", "region_id", "phone", "token", "image", "mode", "pos_merchant_id", "photo_l"]

        params.require(:data).permit(allowed)
    end

end