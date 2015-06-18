class Debt < ActiveRecord::Base

    validates :owner, presence: :true

#   -------------

    has_one :gift, :as => :payable
    belongs_to :owner, polymorphic: :true

#   -------------

    def success?
        if self.id
            true
        else
            false
        end
    end

    def resp_code
        if self.id
            1
        else
            3
        end
    end

    def reason_text
        if self.id
            "This transaction has been approved."
        else
            self.errors.full_messages
        end
    end

    def reason_code
        if self.id
            1
        else
            2
        end
    end

end
# == Schema Information
#
# Table name: debts
#
#  id         :integer         not null, primary key
#  owner_id   :integer
#  owner_type :string(255)
#  amount     :decimal(8, 2)
#  total      :decimal(8, 2)
#  detail     :string(255)
#  created_at :datetime
#  updated_at :datetime
#

