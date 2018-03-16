class MakeUserAccessAssociationsPolymorphic < ActiveRecord::Migration
  def change
    add_column    :user_accesses, :owner_id,   :integer
    add_column    :user_accesses, :owner_type, :string,  length: 32

    # Migrate merchant/affiliate_id's to the new polymorphic system
    UserAccess.all.each do |grant|
        # UserAccess Grants are never associated with both
        grant.owner_id   = (grant.affiliate_id || grant.merchant_id)
        grant.owner_type = (grant.affiliate_id.present? ? "Affiliate" : "Merchant")
        # If neither is set, don't save the record as the above line will set owner_type="Merchant"
        grant.save  if grant.owner_id.present?
    end

    remove_column :user_accesses, :merchant_id,  :integer
    remove_column :user_accesses, :affiliate_id, :integer
  end
end