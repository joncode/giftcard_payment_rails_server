class SupplyItem < ActiveRecord::Base
	HEX_ID_PREFIX = 'si_'
	include HexIdMethods



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