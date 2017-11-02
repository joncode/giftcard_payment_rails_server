class SupplyOrder < ActiveRecord::Base
	HEX_ID_PREFIX = 'so_'
	include HexIdMethods

    before_save :set_delivered_at


	def mark_as_deliverd
		self.update(status: 'delivered', delivered_at: DateTime.now.utc)
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
