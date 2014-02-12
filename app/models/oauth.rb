class Oauth < ActiveRecord::Base
    belongs_to  :owner,    polymorphic: :true, autosave: true

    validates_presence_of :owner_id, :owner_type, :network, :token
    validates :secret, presence: true, :if => :twitter?

private

    def twitter?
        self.network == "twitter"
    end
end
