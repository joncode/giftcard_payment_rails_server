class SupplyOrder < ActiveRecord::Base
	HEX_ID_PREFIX = 'so_'
	include HexIdMethods

    before_save :set_delivered_at

	after_commit :charge_card_for_supplies, on: :create

	def mark_as_deliverd
		self.update(status: 'delivered')
	end

	def destroy
			# DO NOT DELETE RECORDS
		update_column(:active, false)
	end

	def serialize
		x = self.as_json
		x.delete('id')
		x
	end


    def supply_items
        self.form_data['supply_items'] || self.form_data['products'] || []
    end
    alias_method :items, :supply_items

	def confirm_price
		ary_prices = supply_items.map do |hsi|
			si = SupplyItem.find_with(hsi['hex_id'])
			si.price * (hsi['quantity'].to_i || 1)
		end
		cart_total = ary_prices.sum
		if self.price != cart_total
			self.update(price: cart_total)
		end
	end

	def charge_card_for_supplies
		puts "Charge Card for Supplies"
		confirm_price
		card = init_card
		card.save
		if card.active && card.persisted?
			# card created
			# charge the card for the amount
			return OpsStripeToken.charge_card(card, "ItsOnMe order supply charge")
		else
			# card failed
			return card.errors.messages
		end
	end

	def init_card
		# parse cc details into CardStripe input format
			# add client and partner
		h = {
			"stripe_id"=> self.form_data['stripe']['token']['id'],
			"name"=> self.form_data['contact_name'],
			"email"=> self.form_data['contact_email'],
			"merchant_name"=> self.form_data['venue_name'],
			"zip"=> self.form_data['stripe']['token']['card']['address_zip'],
			"last_four"=> self.form_data['stripe']['token']['card']['last4'],
			"brand"=> self.form_data['stripe']['token']['card']['brand'],
			"csv"=> nil,
			"month"=> self.form_data['stripe']['token']['card']['exp_month'],
			"year"=> self.form_data['stripe']['token']['card']['exp_year'],
			"amount"=> self.price,
			"ccy" => self.ccy,
			'country' => self.form_data['stripe']['token']['card']['country'],
			'client_id' => self.form_data['client_id'],
			'partner_id' => self.form_data['partner_id'],
			'partner_type' => self.form_data['partner_type']
		}
		# CardStripe.save will take care of sending to stripe
		CardStripe.create_card_from_hash(h)
	end

private

	def set_delivered_at
		if self.status == 'delivered' && self.delivered_at.nil?
			self.delivered_at = DateTime.now.utc
		end
	end

end

__END__

supply_orders

:hex_id
:price
:ccy
:form_data
:status default: 'open'
:pay_stat default: 'due'
:delivered_at
:active default: true
