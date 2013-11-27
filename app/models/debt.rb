class Debt < ActiveRecord::Base

    has_one :gift, :as => :payable
    belongs_to :owner, polymorphic: :true
    
    validates :owner, presence: :true


end
