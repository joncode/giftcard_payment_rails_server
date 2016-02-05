#######################

####  DO NOT UPDATE THIS FILE OUTSIDE OF drinkboard !!!   ####

####  Update in drinkboard and copy to MT & ADMT   ####

#######################

class ListItem < ActiveRecord::Base

	validates_presence_of :list_step_id, :owner_id, :owner_type

#   -------------

	has_one :list_step
	belongs_to :owner, polymorphic: true

#   -------------

	def self.states index=nil
		states_ary = ["", "yes", "denied", "n/a"]
		return states_ary if index.nil?
		return states_ary[index.to_i]
	end

#   -------------

	def step
		ListStep.where(id: list_step_id).first
	end

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