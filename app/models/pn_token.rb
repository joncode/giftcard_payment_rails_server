class PnToken < ActiveRecord::Base
    attr_accessible :pn_token, :user_id

    belongs_to :user

    validates :pn_token, uniqueness: true

    def pn_token
        token = super
        token.gsub('<','').gsub('>','')
    end
end
