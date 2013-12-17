class Debt < ActiveRecord::Base

    has_one :gift, :as => :payable
    belongs_to :owner, polymorphic: :true

    validates :owner, presence: :true

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
            2
        end
    end

    def reason_text
        if self.id
            "Transaction approved."
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
