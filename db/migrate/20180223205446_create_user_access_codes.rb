class CreateUserAccessCodes < ActiveRecord::Migration
  def change
    create_table :user_access_codes do |t|
      t.integer  :merchant_id
      t.integer  :affiliate_id
      t.string   :code,               null: false
      t.integer  :role_id,            null: false
      t.integer  :created_by
      t.boolean  :approval_required,  null: false,  default: true
      t.boolean  :active,             null: false,  default: true
    end
  end
end
