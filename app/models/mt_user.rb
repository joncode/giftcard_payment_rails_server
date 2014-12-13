class MtUser < Mtmodel
	self.table_name = "mt_users"

	has_one  :setting, foreign_key: :user_id
  	has_many :pn_tokens
    has_many :invites, dependent: :destroy, foreign_key: :user_id
    has_many :merchants, :through => :invites

	def merchants
		if self.admin?
			Merchant.all
		else
			super.where(active: true)
		end
	end

	def name
    	if self.last_name.blank?
    	  "#{self.first_name}"
    	else
    	  "#{self.first_name} #{self.last_name}"
    	end
	end

end
