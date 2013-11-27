class Debt < ActiveRecord::Base

    has_one :gift, :as => :payable
    belongs_to :owner, polymorphic: :true

    # attr_accessible :owner, :amount
    validates :owner, presence: :true


end
