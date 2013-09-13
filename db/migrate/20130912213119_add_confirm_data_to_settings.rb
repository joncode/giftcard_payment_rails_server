class AddConfirmDataToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :confirm_email_token, :string
    add_column :settings, :confirm_phone_token, :string
    add_column :settings, :reset_token, :string
    add_column :settings, :confirm_phone_flag, :boolean, default: false
    add_column :settings, :confirm_email_flag, :boolean, default: false
    add_column :settings, :confirm_phone_token_sent_at, :datetime
    add_column :settings, :confirm_email_token_sent_at, :datetime
    add_column :settings, :reset_token_sent_at, :datetime
  end
end
