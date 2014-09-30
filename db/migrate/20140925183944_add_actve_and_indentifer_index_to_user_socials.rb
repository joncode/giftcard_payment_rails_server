class AddActveAndIndentiferIndexToUserSocials < ActiveRecord::Migration
  	def change
  		add_index :user_socials, [:active, :identifier]
  	end
end
