class ListStep < ActiveRecord::Base

#   -------------

	validates_presence_of :type_of, :owner_type, :name

#   -------------


#   -------------

	def type_of= new_type
		if [:list, :step].include?(new_type)
			super
		end
	end

#   -------------

end

      # t.string :name
      # t.string :type_of
      # t.string :owner_type
      # t.integer :position


# table list_steps
# 	id (int) primary key
# 	name (string) required
# 	type_of ( string - enum) - :list, :step
# 	owner_type (string enum) - :merchant, :affiliate, :user, :at_user, :mt_user, :step
# 	position (int)