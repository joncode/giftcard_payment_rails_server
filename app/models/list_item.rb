class ListItem < ActiveRecord::Base

#   -------------

	validates_presence_of :list_step_id, :owner_id, :owner_type

#   -------------

	def self.states
		["", "yes", "denied", "n/a"]
	end

#   -------------

end

      # t.integer :owner_id
      # t.string :owner_type
      # t.integer :list_step_id
      # t.string :state

# table list_items
# 	id (int) primary key
# 	owner_id (int)
# 	owner_type (string) - :merchant, :affiliate, :user, :at_user, :mt_user, :step
# 	list_step_id (int)
# 	state (string) default ""
# 		- "", yes, denied, n/a