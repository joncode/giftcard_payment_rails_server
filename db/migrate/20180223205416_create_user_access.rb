class CreateUserAccess < ActiveRecord::Migration
  def change
    create_table :user_accesses do |t|
      t.integer   :user_id
      t.integer   :merchant_id
      t.integer   :affiliate_id
      t.integer   :role_id,      null: false
      t.datetime  :approved_at
      t.integer   :approved_by  # user id
      t.boolean   :active,       null: false,  default: true
    end
  end
end
