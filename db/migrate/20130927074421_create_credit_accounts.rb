class CreateCreditAccounts < ActiveRecord::Migration
  def change
    create_table :credit_accounts do |t|
      t.string :owner
      t.integer :owner_id

      t.timestamps
    end
  end
end
