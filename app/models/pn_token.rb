class PnToken < ActiveRecord::Base
    attr_accessible :pn_token, :user_id

    belongs_to :user

    after_create :register

    validates :pn_token, uniqueness: true

    def pn_token
        token = super
        token.gsub('<','').gsub('>','').gsub(' ','')
    end

private

    def register

    end
end
