class AddTokenToMenuItems < ActiveRecord::Migration
	def up
	  	add_column :menu_items, :token, :string
	  	generate_tokens
	end

	def down
		remove_column :menu_items, :token
	end

	def generate_tokens
        MenuItem.find_in_batches do |group|
            group.each do |item|
            	item.save
            end
        end
	end

end
