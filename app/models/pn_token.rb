class PnToken < ActiveRecord::Base
    attr_accessible :pn_token, :user_id

    belongs_to :user

    after_create :register

    validates :pn_token, uniqueness: true
    validates_presence_of :user_id

    def pn_token
        token = super
        convert_token(token)
    end

    def pn_token=(token)
        converted_token = convert_token(token)
        super(converted_token)
    end

private

    def register
        user_alias  = self.user.ua_alias
            # send the pn token to urbanairship as a register
        Urbanairship.register_device(self.pn_token, :alias => user_alias )
    end

    def convert_token(token)
        token.gsub('<','').gsub('>','').gsub(' ','')
    end
end
