class AddStatusAndMsgToUserSocials < ActiveRecord::Migration
  def change
    add_column :user_socials, :status, :string, default: 'live'
    add_column :user_socials, :msg, :string
  end
end
