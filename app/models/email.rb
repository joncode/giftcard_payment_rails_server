module Email

######   Order

    def notify_giver_order_complete
        puts "emailing the gift giver for #{self.id}"
        # notify the giver via email
        # order is self here
        gift = self.gift
        Resque.enqueue(EmailJob, 'notify_giver_order_complete', gift.giver_id , {:gift_id => gift.id})
    end

#######   Sale

    def notify_receiver
        # self is sale
        gift = self.gift
        if gift.receiver_email
            puts "emailing the gift receiver for #{gift.id}"
            # notify the receiver via email
            user_id = gift.receiver_id.nil? ?  'NID' : gift.receiver_id
            Resque.enqueue(EmailJob, 'notify_receiver', user_id , {:gift_id => gift.id, :email => gift.receiver_email})
        end
    end

    def invoice_giver
        # self is sale
        gift = self.gift
        puts "emailing the gift giver for #{gift.id}"
        # notify the giver via email
        Resque.enqueue(EmailJob, 'invoice_giver', gift.giver_id , {:gift_id => gift.id})
    end

#######   User

    def confirm_email
        # self is user
        if self.email
            if self.confirm[0] == '0'
                if Rails.env.production?
                    Resque.enqueue(EmailJob, 'confirm_email', self.id , {})
                end
            end
        end
    end

    def email_gift_collected gift
        if gift.receiver_email
            puts "emailing the gift giver that gift has been collected for #{gift.id}"
            if Rails.env.production?
                # notify the giver via email
                Resque.enqueue(EmailJob, 'notify_giver_created_user', gift.giver_id , {:gift_id => gift.id})
            end
        end
    end


end