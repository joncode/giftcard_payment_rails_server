class CreateGift
# CreateGift    - class to make gifts

#     charge
    def charge

    end
#     regift
    def regift

    end
#     promotional
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
    def create

    end

#     sets appropriate statuses
    def status=

    end
#     saves the gift record
    def save

    end
#     sends the messages
    def messenge
#         - new gift message to the merchant
#         - invoice giver if SALE or CREDIT ACCOUNT
#         - alert campaign if CAMPAIGN
#         - send push note to receiver if db user
#         - sends email to receiver
#         - sends text to receiver
#         - sends message thru fb, twitter to receiver
#         - post to drinkboard gifts twitter
    end

end







