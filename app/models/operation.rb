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

    def self.collection_for_select gift
        collection = []
        if gift.status == "redeemed"
            collection << ["Unredeem", "unredeem"]
        elsif ["open", "incomplete", "notified"].include?(gift.status)
            if gift.giver_type == 'User'
                collection << ["Return to Sender", "return_to_sender"]
            end
            collection << ["Change Receiver", "change_receiver"]
        end
        if ['open'].include?(gift.status)
            collection << ['Notify', 'notify']
        end
        if ['notified'].include?(gift.status) && !gift.token_fresh?
            collection << ['Refresh Token', 'notify']
        end
        if ["open", "notified"].include?(gift.status)
            collection << ["Redeem", "redeem_gift"]
        end

        if ["schedule"].include?(gift.status)
            # collection << ["Reschedule", "reschedule"]
            if gift.giver_type == 'User'
                collection << ["Return to Sender & Deliver", "return_to_sender"]
            end
            collection << ["Change Receiver & Deliver", "change_receiver"]
        end
        if gift.payable_type == "Sale"
            collection << ["Refund/Cancel", "refund_cancel"]
            collection << ["Refund/Live", "refund_live"]
        end
        if gift.active
            collection << ["Deactivate", "deactivate"]
        else
            collection << ["Activate", "activate"]
        end
        collection
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

