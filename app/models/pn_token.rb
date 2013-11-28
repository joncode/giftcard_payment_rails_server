class PnToken < ActiveRecord::Base
    #attr_accessible :pn_token, :user_id

    belongs_to :user

    validates :pn_token, uniqueness: true, length: { minimum: 23 }
    validates_presence_of :user_id


    after_save :register

    def pn_token=(token)
        converted_token = convert_token(token)
        super(converted_token)
    end

    def convert_token(token)
        token.gsub('<','').gsub('>','').gsub(' ','')
    end

    def self.convert_token(token)
        token.gsub('<','').gsub('>','').gsub(' ','')
    end

    def ua_alias
            # move this to pn_token.rb
        adj_user_id = self.user_id + NUMBER_ID
        "user-#{adj_user_id}"
    end

private

    def register
        Resque.enqueue(RegisterPushJob, self.id)
    end

end
# == Schema Information
#
# Table name: pn_tokens
#
#  id       :integer         not null, primary key
#  user_id  :integer
#  pn_token :string(255)
#

