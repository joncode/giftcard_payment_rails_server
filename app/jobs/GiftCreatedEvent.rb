class GiftCreatedEvent

    @queue = :after_save

    def self.perform gift_id
      _signature = "[job GiftCreatedEvent :: perform(#{gift_id})]"
      puts "\n\n#{_signature}"
    	gift = Gift.find gift_id
      puts " | Gift: #{gift.inspect}"

        if gift.pay_stat != "payment_error"
            Accountant.gift_created_event(gift)

            unless gift.status == 'schedule'
                puts "\n#{_signature}  -> notify_via_facebook()"
                notify_via_facebook gift

                # Disable notifying for cat300 (Standard gift) because these are already notified after creation.
                # However, 301 (StndRegift) and 307 (StndBoom) may still need to notify.
                # (I don't know this portion of the system well enough to say.)
                if gift.cat != 300
                    puts "\n#{_signature}  -> gift.notify_via_text()"
                    gift.notify_via_text
                else
                    puts "\n#{_signature}  Cat 300; Not notifying via text."
                end
            end

            # PointsForSaleJob.perform gift_id
            if gift.cat == 300
                begin
                    puts "\n#{_signature}  -> GiftPurchasePromotionJob.perform"
                    GiftPurchasePromotionJob.perform(gift)
                rescue => e
                    puts "500 Internal #{e.inspect}"
                end
                Alert.perform("GIFT_PURCHASED_SYS", gift)
                Alert.perform("GIFT_PURCHASED_MT", gift)
            end

        end
    end

    def self.notify_via_facebook gift
        begin
            res = OpsFacebook.notify_receiver_from_giver(gift)
            puts "Facebook reponse #{res.inspect}"
        rescue => e
            puts "500 Internal (GiftCreatedEvent) failed on facebook #{e.inspect}"
        end
    end

end

