module Cron

    def check_tokens
        pactive     = Provider.all
        pdeactive   = Provider.where(active: false)
        ps          = pactive + pdeactive
        bads = ps.map { |p| p.token.length != 22  }
        pattr(:token, bads)
    end

end