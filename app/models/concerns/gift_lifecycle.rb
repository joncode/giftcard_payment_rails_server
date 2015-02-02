module GiftLifecycle
    extend ActiveSupport::Concern

    def notify(redeem=true)
        if notifiable?
            if (self.new_token_at.nil? || self.new_token_at < reset_time)
                current_time   = Time.now.utc
                #self.new_token_at = current_time
                if redeem
                    include_status = if self.status == 'open'
                        #self.status = 'notified'
                        " status = 'notified' ,"
                    else
                        ""
                    end
                    include_notify = if self.notified_at.nil?
                        #self.notified_at = current_time
                        " notified_at = '#{current_time}' ,"
                    else
                        ""
                    end
                    sql = "UPDATE gifts SET #{include_status} #{include_notify} token = nextval('gift_token_seq'), new_token_at = '#{current_time}' WHERE id = #{self.id};"
                    # RESQUE -> POST GIFT TO MERCHANTS FIREBASE
                        # SAVE THGE GIFTS BY MERCHANT ID & RESET_TIME OR CURRENT DATE
                else
                    sql = "UPDATE gifts SET status = 'notified', token = nextval('gift_token_seq'), notified_at = '#{current_time}' WHERE id = #{self.id};"
                end

                Gift.connection.execute(sql)
                self.reload
                true
            else
                true
            end
        end
    end

    def notifiable?
        return self.status == 'open' || self.status == 'notified'
    end

    def redeem_gift(server_code=nil)
        if self.status == 'notified'
            self.status      = 'redeemed'
            self.redeemed_at = Time.now.utc
            self.server      = server_code
            self.order_num   = make_order_num(self.id)
            if self.save
                Resque.enqueue(PointsForCompletionJob, self.id)
                true
            else
                false
            end
        else
            #=> gift cannot be redeemed, its not notified
            false
        end
    end

    def partial_redeem(pos_obj)
        prev_value   = self.balance
        self.balance -= pos_obj.applied_value
        detail_msg   = self.detail || ""
        redemption_msg = "#{number_to_currency(pos_obj.applied_value/100.0)} was paid with ticket # #{pos_obj.ticket_num}\n"
        self.detail  = redemption_msg + detail_msg
        self.save
        r = Redemption.new
        r.gift_id = self.id
        r.gift_prev_value = prev_value
        r.gift_next_value = self.balance
        r.amount = pos_obj.applied_value
        r.ticket_id = pos_obj.ticket_id
        r.save
    end

    def pos_redeem(ticket_num, pos_merchant_id)
        pos_hsh = { "ticket_num" => ticket_num,
                    "gift_card_id" => self.obscured_id,
                    "pos_merchant_id" => pos_merchant_id,
                    "value" => self.balance }
        pos_obj = Positronics.new(pos_hsh)

        resp    = pos_obj.redeem
        resp["success"] = pos_obj.success?
        if resp["success"]
            if pos_obj.code == 201
                self.partial_redeem(pos_obj)
            elsif pos_obj.code == 200 || pos_obj.code == 206
                self.redeem_gift(nil)
            end
        end
        resp
    end

end