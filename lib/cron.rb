module Cron

    def check_tokens
        bads = get_bad_tokens
        pattr(:token, bads)
    end

private

    def get_bad_tokens
        ps     = Provider.unscoped
        ps.select do |p|
            (p.token.nil?) || (p.token.length != 22)
        end
    end

end