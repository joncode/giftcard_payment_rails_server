class MtUser < ActiveRecord::Base

	# has_one  :setting, foreign_key: :user_id
  	# has_many :pn_tokens
    has_many :invites, dependent: :destroy
    has_many :merchants, :through => :invites, source: :company, source_type: 'Merchant'
    has_many :affiliates, :through => :invites, source: :company, source_type: 'Affiliate'

#   -------------

    def companies
		merchants.where(active: true) + affiliates.where(active: true)
    end

	def merchants
		if self.admin?
			Merchant.all
		else
			super.where(active: true)
		end
	end

	def affiliates
		if self.admin?
			Affiliate.all
		else
			super.where(active: true)
		end
	end

#   -------------

	def name
    	if self.last_name.blank?
    	  "#{self.first_name}"
    	else
    	  "#{self.first_name} #{self.last_name}"
    	end
	end

    def get_photo
		if self.photo
			self.photo
		else
            nil
		end
	end

end


