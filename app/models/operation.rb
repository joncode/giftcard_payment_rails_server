class Operation < ActiveRecord::Base

    belongs_to :at_user, foreign_key: :user_id
    validates_presence_of :obj_id, :obj_type, :user_id

# "unpaid"         = charge was denied at Point of purchase by credit card processor
# "incomplete"     = charge accepted by processor - gift not redeemable
# "open"           = charge accepted by processor - Gift is redeemeable
# "notified"       = charge accepted by processor - Gift is redeemeable
# "redeemed"       = charge accepted by processor - Gift is completed
# "regift"         = charge accepted by processor - Gift is transfered and redeemable or "incomplete"
# "void"           = charge accepted by processor - voided before completion of processor ( < 3 days to complete cc charge) - money refunded via cc VOID  system      - gift NOT redeemed (nothing owed to merchant)
# "cancel"         = charge accepted by processor - voided before completion of processor ( < 3 days to complete cc charge) - money refunded via cc VOID  system      - gift IS redeemd (money owed to merchant)
# "refund_void"    = charge complete by processor - voided AFTER completion of processor  ( > 3 days to complete cc charge) - money refunded via drinkboard liability - gift NOT redeemd (nothing owed to merchant) - made whole via credit card monthly settlement
# "refund_cancel"  = charge complete by processor - voided AFTER completion of processor  ( > 3 days to complete cc charge) - money refunded via drinkboard liability - gift IS redeemd (money owed to merchant)    - made whole via credit card monthly settlement


######  GETTERS and SETTERS

    def status
        GIFT_STATUS_HSH.key(super)
    end

    def status= status_str
        super(GIFT_STATUS_HSH[status_str])
    end

    # def type_of
    #     ADMIN_ACTION_HASH.key(super)
    # end

    # def type_of= type_str
    #     super(ADMIN_ACTION_HASH[type_str])
    # end

    # def obj_type
    #     super.constantize
    # end

    def obj_type= obj_type_const
        super(obj_type_const.to_s)
    end

end

# == Schema Information
#
# Table name: operations
#
#  id         :integer         not null, primary key
#  obj_id     :integer
#  user_id    :integer
#  status     :integer
#  note       :text
#  response   :text
#  created_at :datetime
#  updated_at :datetime
#  type_of    :integer
#  obj_type      :string(255)
#

