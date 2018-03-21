class Resources::MerchantController < ResourcesController

    def handout
        render pdf: "team_code_handout", encoding: :utf8
    end

end
