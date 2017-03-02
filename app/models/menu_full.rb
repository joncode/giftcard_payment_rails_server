class MenuFull < Menu

	before_validation :set_type_of

    default_scope -> { where(type_of: 1) }


private

	def set_type_of
 		self.type_of = 1
	end

end

# == Schema Information
#
# Table name: menus
#
#  id             :integer         not null, primary key
#  merchant_token :string(255)
#  json           :text
#  merchant_id    :integer
#  type_of        :integer
#  edited         :boolean
#  created_at     :datetime
#  updated_at     :datetime
#

