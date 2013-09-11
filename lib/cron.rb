module Cron

    def check_tokens
        bads = get_bad_tokens
        pattr(:token, bads)
    end

    def rebuild_providers
        # run check tokens
        bads = get_bad_tokens
        # get each provider with a bad token
        bads.each do |provider|
            #provider.update_data
        end
        # call MT for correct information
        # update the provider
    end

private

    def get_bad_tokens
        ps     = Provider.unscoped
        ps.select { |p| p.token.length != 22  }
    end

end