module AuditTrail
    extend ActiveSupport::Concern

	def set_audit_trail current_value, new_hsh
		current_value ||= {}
		new_hsh ||= {}
		raise unless current_value.kind_of?(Hash) && new_hsh.kind_of?(Hash)
		dt = DateTime.now.utc
		dti = dt.to_i.to_s
		new_hsh[:time] = dt
		current_value[dti] = new_hsh
		current_value['CURRENT'] = new_hsh
		current_value
	end

	def get_audit_trail x, option=nil
		if option.nil? || !x['CURRENT']
			x
		else
			x['CURRENT'][option.to_s] || x['CURRENT']
		end
	end

end