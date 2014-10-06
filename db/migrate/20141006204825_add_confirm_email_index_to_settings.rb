class AddConfirmEmailIndexToSettings < ActiveRecord::Migration
  def change
  	add_index :settings, :confirm_email_token
  end
end
