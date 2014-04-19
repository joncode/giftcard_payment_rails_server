class AddPosMerchantIdToRedeemsAndProviders < ActiveRecord::Migration

    def up
        add_column :redeems,   :pos_merchant_id, :integer
        add_column :providers, :pos_merchant_id, :integer
        add_index  :providers, :pos_merchant_id
        add_index  :redeems,   :gift_id
    end

    def down
        remove_index  :redeems,   :gift_id
        remove_index  :providers, :pos_merchant_id
        remove_column :providers, :pos_merchant_id
        remove_column :redeems,   :pos_merchant_id
    end
end
