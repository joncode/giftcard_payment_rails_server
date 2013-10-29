class PnToken < ActiveRecord::Base
    attr_accessible :pn_token, :user_id

    belongs_to :user

    after_create :register

    validates :pn_token, uniqueness: true
    validates_presence_of :user_id, :pn_token

    def pn_token
        token = super
        convert_token(token)
    end

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

