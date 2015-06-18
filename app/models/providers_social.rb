class ProvidersSocial  < ActiveRecord::Base
    self.table_name = "providers_socials"

#   -------------

	validates :social_id, :uniqueness => { scope: :provider_id }

#   -------------

    belongs_to :provider
    belongs_to :social


end



# == Schema Information
#
# Table name: providers_socials
#
#  provider_id :integer         not null
#  social_id   :integer         not null
#

