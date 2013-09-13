module Cron

    def check_tokens
        get_bad_user_remember_tokens
        bad_ps    = get_bad_provider_tokens
        bads_admt = get_bad_admt_tokens
        bads      = bad_ps + bads_admt
        pattr(:token, bads)
    end

private

    def get_bad_provider_tokens
        ps     = Provider.unscoped
        ps.select do |p|
            (p.token.nil?) || (p.token.length != 22)
        end
    end

    def get_bad_admt_tokens
        ps     = AdminToken.unscoped
        ps.select do |p|
            (p.token.nil?) || (p.token.length != 22)
        end
    end

    def get_bad_user_remember_tokens
        ps     = User.unscoped
        bads = ps.select do |p|
            (p.remember_token.nil?) || (p.remember_token.length != 22)
        end
        pattr(:remember_token, bads)
    end

end