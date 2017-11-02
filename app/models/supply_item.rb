class SupplyItem < ActiveRecord::Base
	HEX_ID_PREFIX = 'si_'
	include HexIdMethods


	def destroy
			# DO NOT DELETE RECORDS
		update_column(:active, false)
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