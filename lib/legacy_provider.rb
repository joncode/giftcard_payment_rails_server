module LegacyProvider

    def check_provider_merchants

        ps = Provider.unscoped
        total = ps.count
        correct     = 0
        no_merchant = 0
        no_token    = 0
        live_ps     = 0
        ps.each do |p|
            if p.token
                if merchant = Merchant.find_by_token(p.token)
                    correct += 1
                    puts "provider #{log_obj(p)} correct | active = #{p.active} | live = `#{p.sd_location_id}`"
                else
                    no_merchant += 1
                    puts "provider #{log_obj(p)} no merchant | active = #{p.active} | live = `#{p.sd_location_id}`"
                end
            else
                no_token += 1
                if p.active
                    puts "provider #{log_obj(p)} PROBLEM ________________________________________________________"
                else
                    puts "provider #{log_obj(p)} bad deactive"
                end
            end
            if p.active
                live_ps += 1
            end
        end
        processed = correct + no_merchant + no_token
        puts "SCORECARD - total = #{total}"
        puts "----------- correct = #{correct}"
        puts "----------- no merchant = #{no_merchant}"
        puts "----------- no token = #{no_token}"
        puts " confirm answers #{total} == #{processed}"
        puts "currently #{live_ps} in-app providers"

    end

private

    def log_obj obj
        " #{obj.id} | #{obj.name} "
    end

end