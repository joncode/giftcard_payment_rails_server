class SupplyItem < ActiveRecord::Base
	HEX_ID_PREFIX = 'si_'
	include HexIdMethods


	def destroy
			# DO NOT DELETE RECORDS
		update_column(:active, false)
	end

	def serialize
		x = self.as_json
		x.delete('id')
		x
	end

end


__END__


supply_items

:hex_id
:name
:price
:ccy
:detail
:photo_url
:active default: true