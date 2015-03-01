class ProvidersSocial  < ActiveRecord::Base
    self.table_name = "providers_socials"

    belongs_to :provider
    belongs_to :social

	validates :social_id, :uniqueness => { scope: :provider_id }

end



# == Schema Information
#
# Table name: providers_socials
#
#  provider_id :integer         not null
#  social_id   :integer         not null
#

