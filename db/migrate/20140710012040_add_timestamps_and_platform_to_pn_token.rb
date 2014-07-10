class AddTimestampsAndPlatformToPnToken < ActiveRecord::Migration
	def change
		add_column :pn_tokens, :platform, 	:string,  default: "ios"
		add_column :pn_tokens, :created_at, :datetime
		add_column :pn_tokens, :updated_at, :datetime
	end
end
