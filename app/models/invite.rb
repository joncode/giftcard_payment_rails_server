class Invite < ActiveRecord::Base
    include Utility

    belongs_to :mt_user, foreign_key: :user_id
    belongs_to :merchant

    before_validation       :generate_invite_tkn
    before_validation       :strip_whitespace_and_fix_case
    validates_presence_of   :invite_tkn, :merchant_id, :email
    validates_uniqueness_of :invite_tkn
    validates :email , format: { with: VALID_EMAIL_REGEX }

    before_save { |invite| invite.email = email.downcase  }

    default_scope -> { where(active: true) }

    def serialize
        mt_user = self.mt_user
        emp  = self.serializable_hash only: [:code, :rank, :general]
        emp["eid"]          = self.id
        emp["photo"]        = mt_user.photo
        emp["first_name"]   = mt_user.first_name
        emp["last_name"]    = mt_user.last_name
        emp["email"]        = mt_user.email
        emp["phone"]        = mt_user.phone
        return emp
    end

    def admt_serialize
        mt_user = self.mt_user
        emp  = self.serializable_hash only: [:code, :rank, :general]
        emp["eid"]          = self.id
        emp["photo"]        = mt_user.photo
        emp["first_name"]   = mt_user.first_name
        emp["last_name"]    = mt_user.last_name
        emp["email"]        = mt_user.email
        emp["phone"]        = mt_user.phone

        return emp
    end

    def name
        self.mt_user.name
    end

    #   getters and setters

    def clearance= level
        rank = level
    end

    def clearance
        rank
    end

    def rank
        CLEARANCE_HASH.key super
    end

    def rank= level
        level = level.capitalize
        level_integer = CLEARANCE_HASH[level] || 0
        super(level_integer)
    end

    def self.make_token
        self.new.generate_token
    end

private

    def generate_invite_tkn
        if self.invite_tkn.nil?
            self.invite_tkn = generate_token
        end
    end

    def strip_whitespace_and_fix_case
        self.email = self.email.downcase.strip if self.email.present?
    end

end





# == Schema Information
#
# Table name: invites
#
#  id           :integer         not null, primary key
#  invite_tkn   :string(255)
#  merchant_tkn :string(255)
#  email        :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#  merchant_id  :integer
#  clearance    :string(255)     default("staff")
#  active       :boolean         default(TRUE)
#  code         :string(255)
#  user_id      :integer
#  rank         :integer         default(0)
#  general      :boolean         default(FALSE)
#

# Employee
#     code
