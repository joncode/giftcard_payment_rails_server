module GiftLifecycle
    extend ActiveSupport::Concern
    include MoneyHelper

    def read(client_id)
        if notifiable?
            send_open_push = (self.status == 'open')
            if self.status == 'open' || self.notified_at.nil? || self.rec_client_id.nil?
                self.status = 'notified'
                self.notified_at = DateTime.now.utc
                self.rec_client_id = client_id
            end
            if save
                Relay.send_push_thank_you(gift) if send_open_push
                true
            else
                false
            end
        else
            false
        end
    end

    def notify(loc_id=nil, client_id=nil)
        if notifiable?
            if (self.new_token_at.nil? || self.new_token_at < reset_time)

                current_time   = Time.now.utc

                include_status = if self.status == 'open'
                    #self.status = 'notified'
                    " status = 'notified' ,"
                else ; "" ; end

                include_notify = if self.notified_at.nil?
                    #self.notified_at = current_time
                    " notified_at = '#{current_time}' ,"
                else ; "" ; end

                change_merchant = if (loc_id.to_i > 0)
                    " merchant_id = #{loc_id.to_i} ,"
                else ; "" ; end

                sql = "UPDATE gifts SET #{include_status} #{include_notify} #{change_merchant} \
token = nextval('gift_token_seq'), new_token_at = '#{current_time}' WHERE id = #{self.id};"

                Gift.connection.execute(sql)
                reload

                Resque.enqueue(GiftAfterSaveJob, self.id)
                # Alert.perform("GIFT_NOTIFIED_MT", self) if self.status == 'notified'
                true
            else
                true
            end
        else
            false
        end
    end

    def notifiable?
        return self.status == 'open' || self.status == 'notified'
    end

#   -------------

    def redeem_gift(server_code=nil, loc_id=nil, r_sys_type_of=1, pos_obj=nil, redemption=nil)
        # if loc_id - do multi loc redemption
        if self.status == 'notified'
            self.status      = 'redeemed'
            self.balance     = 0
            self.redeemed_at = Time.now.utc
            self.server      = server_code if server_code
            self.order_num   = make_order_num(self.id)
            if redemption.nil?
                r = Redemption.init_with_gift(self, loc_id, r_sys_type_of)
            else
                r = redemption
                r.reload
                if r.status == 'done'
                    return true
                end
            end
            begin
                if pos_obj
                    r.req_json = pos_obj.request.as_json if r.req_json.nil?
                    r.resp_json = pos_obj.response.as_json
                    r.ticket_id = pos_obj.ticket_id
                end
            rescue => e
                OpsTwilio.text_devs msg: "Request/Response JSON not working"
            end
            r.status = 'done'
            r.gift_next_value = self.balance
            self.redemptions << r
            if save
                puts "\n gift #{self.id} is being redeemed with redemption #{r.id}\n"
                Resque.enqueue(GiftRedeemedEvent, self.id, r.id)
                true
            else
                puts "\n (68) gift #{self.id} failed redemption #{self.errors.messages.inspect} #{r.errors.messages.inspect}\n"
                false
            end
        else
            #=> gift cannot be redeemed, its not notified
            false
        end
    end

    def redeem_gift_for_amount(amount, redemption_merchant, server_code)
        prev_value     = self.balance
        self.balance   -= amount
        detail_msg     = self.detail || ""
        redemption_msg = "#{display_money(cents: amount, ccy: self.ccy)} was paid on \
#{TimeGem.change_time_to_zone(Time.now.utc, redemption_merchant.zone)}\n"
        self.detail    = redemption_msg + detail_msg
        r = Redemption.init_with_gift(self, redemption_merchant.id, redemption_merchant.r_sys)
        r.gift_prev_value = prev_value
        r.gift_next_value = self.balance
        r.amount          = amount
        r.status = 'done'
        # r.ticket_id       = pos_obj.ticket_id
        self.redemptions << r
        if save
            puts "\n gift #{self.id} is partial redeemed with redemption #{r.id} with value #{amount}\n"
            Resque.enqueue(GiftRedeemedEvent, self.id, r.id)
            true
        else
            puts "\n (94) gift #{self.id} failed redemption #{self.errors.messages.inspect} #{r.errors.messages.inspect}\n"
            false
        end
    end

    def partial_redeem(pos_obj, loc_id=nil, redemption=nil)
        prev_value     = self.balance
        self.balance   -= pos_obj.applied_value
        detail_msg     = self.detail || ""
        redemption_msg = "#{display_money(cents: pos_obj.applied_value, ccy: pos_obj.ccy)} was paid with check # #{pos_obj.ticket_num}\n"
        self.detail    = redemption_msg + detail_msg
        if redemption.nil?
            r = Redemption.init_with_gift(self, loc_id, r_sys_type_of)
        else
            r = redemption
            r.reload
            if r.status == 'done'
                # already redeemed
                return true
            end
        end
        r.gift_prev_value = prev_value
        r.gift_next_value = self.balance
        r.amount          = pos_obj.applied_value
        r.ticket_id       = pos_obj.ticket_id
        r.status = 'done'
        begin
            if pos_obj
                r.req_json = pos_obj.request.as_json if r.req_json.nil?
                r.resp_json = pos_obj.response.as_json
            end
        rescue => e
            OpsTwilio.text_devs msg: "Request/Response JSON not working"
        end
        self.redemptions << r
        if save
            puts "\n (134) gift #{self.id} is partial redeemed with redemption #{r.id} with value #{pos_obj.applied_value}\n"
            Resque.enqueue(GiftRedeemedEvent, self.id, r.id)
            true
        else
            puts "\n (138) gift #{self.id} failed redemption #{self.errors.messages.inspect} #{r.errors.messages.inspect}\n"
            false
        end
    end

    def pos_redeem(ticket_num, pos_merchant_id, tender_type_id, loc_id=nil, amount=nil)
        # if loc_id - do multi loc redemption

        puts "\n HERE IN POS REDEEM - \n ticket_number = #{ticket_num} , pos_merchant_id = #{pos_merchant_id} \
, tender_type_id = #{tender_type_id} , loc_id = |#{loc_id}|, amount = |#{amount}|"

        if ticket_num.nil? || pos_merchant_id.nil? || tender_type_id.nil?
            return {'success' => false, "response_text" => "Data missing please contact support@itson.me"}
        end

        omnivore = Omnivore.init_with_gift(self, ticket_num, amount, loc_id)
        resp = omnivore.redeem

        puts "\nHere is the pos_redeem resp = #{resp.inspect}\n"

        if omnivore.success?
            if omnivore.code == 201
                partial_redeem(omnivore, loc_id)
            elsif omnivore.code == 200 || omnivore.code == 206
                redeem_gift(nil, loc_id, :pos, omnivore)
            end
            resp['success'] = true
        else
            resp['success'] = false
        end
        resp
    end

    def zapper_redemption( qrcode, merchant, amount )

        amount = amount || self.balance

        unique_id = 'rd_' + self.id.to_s + '_' + SecureRandom.hex(2)

        zapper_request = OpsZapper.make_request_hsh(self, qrcode, amount, unique_id)

        r = Redemption.new(gift_id: self.id, amount: amount, type_of: :zapper, status: 'pending',
                gift_prev_value: self.value_cents, gift_next_value: self.value_cents,
                req_json: zapper_request, merchant_id: merchant.id )

        if r.save
            return { 'success' => true , "redemption" => r }
        else
            return { 'success' => false , "response_code" => "SERVER_UNAVAILABLE", "response_text" => "database unavailable" }
        end
    end

    def zapper_redeem_async(redemption)
        r = redemption
        zapper_request = r.request
        zapper_request['redemption_id'] = 'rd_' + r.id.to_s
        zapper_obj = OpsZapper.new(zapper_request)
        resp = zapper_obj.redeem_gift
        if zapper_obj.success?
            if zapper_obj.code == 201
                partial_redeem(zapper_obj, merchant.id, r)
            elsif zapper_obj.code == 200 || zapper_obj.code == 206
                redeem_gift(nil, merchant.id, :zapper, zapper_obj, r)
            end
            resp['success'] = true
        else
            resp['success'] = false
        end
        puts "ZAPPER resp = #{resp.inspect}"
        resp
    end

    def zapper_redeem qrcode, merchant, amount=nil

        amount = amount || self.balance

        unique_id = 'rd_' + self.id.to_s + '_' + SecureRandom.hex(2)

        zapper_request = OpsZapper.make_request_hsh(self, qrcode, amount, unique_id)

        r = Redemption.new(gift_id: self.id, amount: amount, type_of: :zapper, status: 'pending',
                gift_prev_value: self.value_cents, gift_next_value: self.value_cents,
                req_json: zapper_request, merchant_id: merchant.id )

        if r.save
            zapper_request['redemption_id'] = 'rd_' + r.id.to_s
            zapper_obj = OpsZapper.new(zapper_request)
            resp = zapper_obj.redeem_gift
            if zapper_obj.success?
                if zapper_obj.code == 201
                    partial_redeem(zapper_obj, merchant.id, r)
                elsif zapper_obj.code == 200 || zapper_obj.code == 206
                    redeem_gift(nil, merchant.id, :zapper, zapper_obj, r)
                end
                resp['success'] = true
            else
                resp['success'] = false
            end
        else
            return { 'success' => false , "response_code" => "SERVER_UNAVAILABLE", "response_text" => "database unavailable" }
        end
        puts "ZAPPER resp = #{resp.inspect}"
        resp
    end

#   -------------

    def unredeem
        if self.status == 'redeemed'
            Resque.enqueue(GiftUnredeemEvent, self.id)
            update(status: 'notified' , redeemed_at: nil, order_num: nil)
        end
    end

#   -------------

    def brand_card_ids
        if self.brand_card
            brand_card_ids = self.cart_ary.map do |item|
                item['pos_item_id']
            end
            return brand_card_ids.compact
        else
            return []
        end
    end

#   -------------

    def expire_gift
        if update(status: "expired", redeemed_at: Time.now.utc)
            if self.payable_type == 'Proto'
                pj = self.proto_join
                if pj && self.payable.camp
                    pj.update(gift_id: nil)
                end
            end
            fire_after_save_queue(self.client_id)
        end
    end

#   -------------   MDOT methods

    def old_read(client_id)
        if notifiable?
            send_open_push = (self.status == 'open')

            include_status = if self.status == 'open'
                " status = 'notified' ,"
            else ; "" ; end

            include_notify = if self.notified_at.nil?
                " notified_at = '#{DateTime.now.utc}' ,"
            else ; "" ; end

            include_rec_client_id = if (client_id.to_i > 0)
                " rec_client_id = #{client_id.to_i} ,"
            else ; "" ; end

            sql = "UPDATE gifts SET #{include_status} #{include_notify} \
#{include_rec_client_id} token = nextval('gift_token_seq') WHERE id = #{self.id};"

            Gift.connection.execute(sql)
            reload

            Relay.send_push_thank_you(gift) if send_open_push
            true
        else
            false
        end
    end

    def old_notify(loc_id=nil, client_id=nil)
        if notifiable?
            if (self.new_token_at.nil? || self.new_token_at < reset_time)

                current_time   = Time.now.utc

                include_status = if self.status == 'open'
                    #self.status = 'notified'
                    " status = 'notified' ,"
                else ; "" ; end

                include_notify = if self.notified_at.nil?
                    #self.notified_at = current_time
                    " notified_at = '#{current_time}' ,"
                else ; "" ; end

                change_merchant = if (loc_id.to_i > 0)
                    " merchant_id = #{loc_id.to_i} ,"
                else ; "" ; end

                sql = "UPDATE gifts SET #{include_status} #{include_notify} #{change_merchant} \
token = nextval('gift_token_seq'), new_token_at = '#{current_time}' WHERE id = #{self.id};"

                Gift.connection.execute(sql)
                reload

                Resque.enqueue(GiftAfterSaveJob, self.id)
                # Alert.perform("GIFT_NOTIFIED_MT", self) if self.status == 'notified'
                true
            else
                true
            end
        else
            false
        end
    end

end