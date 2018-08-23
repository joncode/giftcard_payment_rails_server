class AddResultToPurchaseVerificationCheck < ActiveRecord::Migration
  def change
    add_column :purchase_verification_checks, :result, :json
  end
end
