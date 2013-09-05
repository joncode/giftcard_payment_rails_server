module Cron

    def check_tokens
        ps     = Provider.unscoped
        bads = ps.map { |p| p.token.length != 22  }
        pattr(:token, bads)
    end

end