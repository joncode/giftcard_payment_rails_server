module AddressHelper


    def set_state_to_abbreviation state_str
    	STATES_PROVINCES[state_str.to_s.downcase.strip.titleize] || state_str
    end












end