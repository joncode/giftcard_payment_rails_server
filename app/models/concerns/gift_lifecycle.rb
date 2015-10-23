module GiftLifecycle
    extend ActiveSupport::Concern

    def notify(already_notified=true, loc_id=nil)
        if notifiable?
            if (self.new_token_at.nil? || self.new_token_at < reset_time)
                current_time   = Time.now.utc
                #self.new_token_at = current_time
                if already_notified
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
                self.update(merchant_id: loc_id.to_i) if (loc_id && loc_id.to_i > 0)
                true
            else
                true
            end
        end
    end

    def notifiable?
        return self.status == 'open' || self.status == 'notified'
    end

    def unredeem
        if self.status == 'redeemed'
            self.update(status: 'notified' , redeemed_at: nil, order_num: nil)
            # delete any redemption registers
            # do not allow un-redemption if the gift is settled
        end
    end

    def redeem_gift(server_code=nil, loc_id=nil, r_sys_type_of=:v1)
        # if loc_id - do multi loc redemption
        if self.status == 'notified'
            self.status      = 'redeemed'
            self.balance     = 0
            self.redeemed_at = Time.now.utc
            self.server      = server_code if server_code
            self.order_num   = make_order_num(self.id)
            r = Redemption.init_with_gift(self, loc_id, r_sys_type_of)
            self.redemptions << r
            if self.save
                puts "\n gift #{self.id} is being redeemed with redemption #{r.id}\n"
                Resque.enqueue(GiftRedeemedEvent, self.id)
                true
            else
                false
            end
        else
            #=> gift cannot be redeemed, its not notified
            false
        end
    end

    def partial_redeem(pos_obj, loc_id=nil)
        prev_value     = self.balance
        self.balance   -= pos_obj.applied_value
        detail_msg     = self.detail || ""
        redemption_msg = "#{number_to_currency(pos_obj.applied_value/100.0)} was paid with check # #{pos_obj.ticket_num}\n"
        self.detail    = redemption_msg + detail_msg
        r = Redemption.init_with_gift(self, loc_id, :positronics)
        r.gift_prev_value = prev_value
        r.gift_next_value = self.balance
        r.amount          = pos_obj.applied_value
        r.ticket_id       = pos_obj.ticket_id
        self.redemptions << r
        if self.save
            Resque.enqueue(GiftRedeemedEvent, self.id)
            true
        else
            false
        end
    end

    def pos_redeem(ticket_num, pos_merchant_id, tender_type_id, loc_id=nil)
        # if loc_id - do multi loc redemption
        return {'success' => false, "response_text" => "Data missing please contact support@itson.me"}  if ticket_num.nil? || pos_merchant_id.nil? || tender_type_id.nil?

        pos_hsh = { "ticket_num" => ticket_num,
                    "gift_card_id" => self.obscured_id,
                    "pos_merchant_id" => pos_merchant_id,
                    "tender_type_id" => tender_type_id,
                    "value" => self.balance,
                    "brand_card_ids_ary" => self.brand_card_ids }

        pos_obj = Omnivore.new(pos_hsh)

        # if pos_merchant_id == "6Tjg7ain"
        #     resp  = pos_obj.direct_redeem
        # else
            resp    = pos_obj.redeem
        # end
        resp["success"] = pos_obj.success?
        if resp["success"]
            if pos_obj.code == 201
                self.partial_redeem(pos_obj, loc_id)
            elsif pos_obj.code == 200 || pos_obj.code == 206
                self.redeem_gift(nil, loc_id, :positronics)
            end
        end
        resp
    end

    def brand_card_ids
        if self.brand_card
            cart_ary = self.ary_of_shopping_cart_as_hash
            brand_card_ids = cart_ary.map do |item|
                item['pos_item_id']
            end
            return brand_card_ids.compact
        else
            return []
        end
    end

end