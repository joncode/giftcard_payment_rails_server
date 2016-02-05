#######################

####  DO NOT UPDATE THIS FILE OUTSIDE OF drinkboard !!!   ####

####  Update in drinkboard and copy to MT & ADMT   ####

#######################

class ListStep < ActiveRecord::Base

#   -------------

	validates_presence_of :type_of, :owner_type, :name

#   -------------

	belongs_to :list_items

#   -------------

	def self.lists
		where(type_of: 'list')
	end

	def self.steps list_id=nil
		return where(type_if: 'step').order(created_at: :asc) if list_nil.nil?
		where(type_if: 'step').order(created_at: :asc)
	end

	def self.type_ofs
		["list", "step"]
	end

	def self.owner_types
		["merchant", "affiliate", "user", "mt_user", "list_step"]
	end

#   -------------

	def type_of= new_type
		nts = new_type.to_s
		if ListStep.type_ofs.include?(nts)
			super nts
		else
			raise "Enum Incorrect"
		end
	end

	def owner_type= new_type
		nts = new_type.to_s
		if ListStep.owner_types.include?(nts)
			super nts
		else
			raise "Enum Incorrect"
		end
	end

	def steps
		ListStep.find_by_sql("SELECT s.* FROM list_steps s, list_items i WHERE s.id = i.list_step_id \
AND i.owner_type = 'ListStep' AND i.owner_id =  #{self.id} ORDER BY created_at asc")
	end

	def items
		if type_of == 'step'
			ListItem.where(list_step_id: self.id)
		else
			itms = steps.map do |step|
				step.items
			end
			itms.flatten
		end
	end

#   -------------

	def destroy
		if type_of == 'step'
			lis = ListItem.where(list_step_id: self.id)
			lis.each(&:destroy)
			super
		else
			# do we destroy the steps too ?
			lis = ListItem.where(owner_type: 'ListStep', owner_id: self.id)
			lis.each do |item|
					# if the step is not used elsewhere delete it
				liss = ListItem.where(list_step_id: item.id)
				if liss.length < 2
					step = item.step
					step.destroy if step.kind_of?(ListStep)
				end
				item.destroy
			end
			super
		end
	end

	def create_step name: form_name
		list = self
		@step = ListStep.new(type_of: 'step', name: name, owner_type: list.owner_type)
		if @step.save
			li = ListItem.new(owner_type: 'ListStep', owner_id: list.id, list_step_id: @step.id)
			if !li.save
				@step.destroy
				@step = ListStep.new(type_of: 'step', name: name, owner_type: list.owner_type)
				@step.errors.add(:list_item, li.errors)
			end
		end
		@step
	end

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