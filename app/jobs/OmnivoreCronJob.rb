
class OmnivoreCronJob
	require 'ops_twilio'

	@queue = :subscription

	def self.perform
		system_downs = Omnivore.locs_sys_down
		puts system_downs.inspect
		tickets_downs = Omnivore.locs_tix_down
		puts tickets_downs.inspect
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
			msg = "Omnivore Location Down #{msg.inspect}"
			puts msg
			OpsTwilio.text_devs msg: msg
		end
	end

end

