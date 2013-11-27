class GiftSale < Gift

private
    
    def pre_init args={}
        total = args["value"].to_f + args["service"].to_f
        giver = args["giver"]
        card  = giver.cards.where(id: args["card_id"]).first
        args.delete("card_id")
        args["payable"] = card.charge total
    end

    def post_init args={}
        puts "\nNotify Receiver #{self.receiver}"

        puts "\nInvoice the giver via email #{self.giver}"
    end


end