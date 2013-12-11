class GiftSale < Gift
    
    def self.create args={}

        if args["receiver_id"]
            receiver = User.unscoped.find(args["receiver_id"])
            if receiver.active == false
                return 'User is no longer in the system , please gift to them with phone, email, facebook, or twitter'
            else
                args["receiver"] = receiver
            end
        end

        args["card"]  = args["giver"].cards.where(id: args["credit_card"]).first
        if args["card"].nil?
            return "We do not have that credit card on record.  Please choose a different card."
        end

        gift = super
        gift.messenger

        gift
    end

    def messenger
        if self.payable.success?
            puts "GiftSale -post_init- \nNotify Receiver via Push #{self.receiver}"
            Relay.send_push_notification(self)
            puts "GiftSale -post_init- \nNotify Receiver via email #{self.receiver}"
            notify_receiver
            puts "GiftSale -post_init- \nInvoice the giver via email #{self.giver}"
            invoice_giver
        end
    end

private

    def pre_init args={}
        args["unique_id"] = unique_id(args["receiver_name"], args["provider_id"])

        card    = args["card"]
        args["amount"] = (args["value"].to_f + args["service"].to_f).to_s

        credit_card_hsh                = card.create_card_hsh args
        credit_card_hsh["giver_id"]    = card.user.id
        credit_card_hsh["provider_id"] = args["provider_id"]

        args["payable"] = Sale.charge_card credit_card_hsh
        args.delete("unique_id")
        args.delete("card")
        args.delete("amount")

    end



    def unique_id receiver_name, provider_id
        "#{receiver_name}_#{provider_id}".gsub(' ','_')
    end

end

# Step 1 - reject suspended / de-active users
# Step 2 - reject card not found
# Step 3 - create revenue
# Step 4 - build the Sale record
#     A1 - build the charge card hash
#     xA2 - create the gift unique_id
#     B - process the credit card thru payment_gateway
#     C - populate the sale_object with the payment_gateway response
#     D - add the card_id to sale_object
# Step 5 - add sale_object to args["payable"]
# Step 6 - remove unneeded keys from args
# Step 7 - call super -> Gift#create
# Step 8 - send messages

