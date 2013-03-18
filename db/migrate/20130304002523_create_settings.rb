class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.integer :user_id
      t.boolean :email_invoice, default: true
      t.boolean :email_redeem, default: true
      t.boolean :email_invite, default: true
      t.boolean :email_follow_up, default: true
      t.boolean :email_receiver_new, default: true
      t.timestamps
    end
  end
end
