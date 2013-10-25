class AddMerchantIdToProviders < ActiveRecord::Migration
    def up
        add_column :providers, :merchant_id, :integer
        add_index  :providers, :merchant_id

        merchant_id_to_providers

    end

    def down
        remove_column :providers, :merchant_id

    end


    def merchant_id_to_providers
        total   = 0
        correct = 0
        bad     = 0
        Provider.unscoped.each do |provider|
            total += 1
            if merchant = Merchant.unscoped.find_by_token(provider.token)
                puts "CPORRECT #{provider.name}|#{provider.id} - adding merchant_id = #{merchant.id}"
                provider.update_attribute(:merchant_id, merchant.id)
                correct += 1
            else
                if provider.active
                    puts "Unable to find merchant for Provider #{provider.name}|#{provider.id}"
                else
                    puts "Delete this Provider #{provider.name}|#{provider.id}"
                    bad += 1
                end
            end
        end
        processed = correct + bad
        puts "SCORECARD - total   = #{total}"
        puts "----------- correct = #{correct}"
        puts "----------- bad     = #{bad}"
        puts " confirm answers #{total} == #{processed}"
    end
end
