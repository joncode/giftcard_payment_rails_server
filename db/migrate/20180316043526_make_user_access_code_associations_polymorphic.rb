class MakeUserAccessCodeAssociationsPolymorphic < ActiveRecord::Migration
  def change
    add_column    :user_access_codes, :owner_id,   :integer
    add_column    :user_access_codes, :owner_type, :string,  length: 32

    # Migrate merchant/affiliate_id's to the new polymorphic system
    UserAccessCode.all.each do |code|
        # UserAccessCodes are never associated with both
        code.owner_id   = (code.affiliate_id || code.merchant_id)
        code.owner_type = (code.affiliate_id.present? ? "Affiliate" : "Merchant")
        # If neither is set, don't save the record as the above line will set owner_type="Merchant"
        code.save  if code.owner_id.present?
    end

    remove_column :user_access_codes, :merchant_id,  :integer
    remove_column :user_access_codes, :affiliate_id, :integer
  end
end
