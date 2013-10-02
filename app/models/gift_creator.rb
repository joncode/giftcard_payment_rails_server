class GiftCreator

    attr_reader :gift_json, :recipient_data, :message, :details

    def initialize params
        @gift_json      = params

    end

    def charge

    end

    def regift
        @recipient_data = JSON.parse @gift_json["receiver"]
        @details        = JSON.parse @gift_json["data"]
        @message        = details["message"]
        old_gift_id     = self.details["regift_id"]
        recipient       = nil

        if self.recipient_data["receiver_id"] && self.recipient_data["receiver_id"] > 0
            unless recipient = User.find(self.recipient_data["receiver_id"])
                puts "!!! APP SUBMITTED USER ID THAT DOESNT EXIST #{recipient_data} !!!"
                recipient = make_user_with_hash(self.recipient_data)
            end
        else
            recipient = make_user_with_hash(self.recipient_data)
        end

        if recipient && (old_gift = Gift.find(old_gift_id.to_i))
            new_gift = old_gift.regift(recipient, message)
            new_gift.save
            old_gift.update_attribute(:status, 'regifted')
            new_gift.set_status_post_payment
            new_gift.save
        else
            new_gift = nil
        end

        new_gift
    end

    def promotional

    end

private
#     Lifecycle :
#     JSON string of gift info received
    def json

    end
#     confirms info of the giver
    def giver

    end
#     checks the validity of the total and service vs the shopping cart
    def money

    end
#     confirms the credit card
    def credit_card

    end
#     checks the receiver for db_user or non
    def receiver

    end
#     saves the gift_items off the shopping cart
    def gift_items

    end
#     creates the payment record OR returns false payment info
#         charges card SALE
#         debts credit CREDITACCOUNT
#         debts campaign CAMPAIGN
    def payment

    end
#     creates the gift record OR returns failure to create gift OR retries
    def gift_create

    end

#     sets appropriate statuses
    def status=

    end
#     saves the gift record
    def gift_save

    end
#     sends the messages
    def messenger
        # unless new_gift.receiver_id.nil?
# #         - send push note to receiver if db user
#             Relay.send_push_notification new_gift
#         end
# #         - new gift message to the merchant
#             Poller.update_merchant_orders self
# #         - invoice giver if SALE or CREDIT ACCOUNT
#             Email.invoice_giver self
# #         - alert campaign if CAMPAIGN
#             Campaign.create_object_with_gift self

# #         - sends email to receiver
#             Email.notify_receiver self

# #         - sends text to receiver
#             Texter.notify_receiver self
# #         - sends message thru fb, twitter to receiver
#             Socializer.send_network_message self
# #         - post to drinkboard gifts twitter
#             Socializer.update_db_twitter self
    end

    def make_user_with_hash(user_data_hash)
        recipient               = User.new
        recipient.first_name    = user_data_hash["name"]
        recipient.email         = user_data_hash["email"]
        recipient.phone         = user_data_hash["phone"]
        recipient.facebook_id   = user_data_hash["facebook_id"]
        recipient.twitter       = user_data_hash["twitter"]
        return recipient
    end

end







