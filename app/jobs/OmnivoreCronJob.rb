
class OmnivoreCronJob
	require 'ops_twilio'

	@queue = :subscription

	def self.perform
		system_downs = O.locs_sys_down
		tickets_downs = O.locs_tix_down
		msg = ""
		[system_downs, tickets_downs].each do |res|
			data = res[:data]
			if res[:status] == 1
				if data.kind_of?(Array) && (data.length > 0)
					data.each do |ol|
						msg += " #{ol.name} #{ol.id} "
					end
				end
			else
				msg += " Error: #{data.message} "
			end
		end
		unless msg.blank?
			puts "Omnivore Location Down 500 Internal #{msg.inspect}"
			OpTwilio.text_devs msg: msg
		end
	end

end

