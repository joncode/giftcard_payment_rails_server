class Resources::MerchantController < ResourcesController

    def handout
        render pdf: "team_code_handout", encoding: :utf8, page_size: nil, page_width: '7.5in', page_height: '10in'
    end

end
