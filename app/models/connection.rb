class Connection  < ActiveRecord::Base
    self.table_name = "providers_socials"

    belongs_to :provider
    belongs_to :social

	validates :social_id, :uniqueness => { scope: :provider_id }

end



