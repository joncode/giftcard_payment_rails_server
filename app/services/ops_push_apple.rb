class OpsPushApple

	class << self

		def send_push(pnt, alert, gift_id=nil)


	        payload = format_payload(alert, gift_id)
	        puts "SEND APNS push |#{pnt.id}| - #{payload} - ALERT= #{alert}"
            return if Rails.env.development? || Rails.env.test?
	        n = APNS::Notification.new(pnt.pn_token, payload)
	        APNS.send_notifications([n])

		end

		def format_payload alert, data=nil
			if alert.kind_of?(Hash)
				payload = alert
			else
				if data
			        if alert.to_s.match(/has been delivered/)
			            payload = { alert: alert.to_s,
			                    title: 'ItsOnMe Gift Delivered!',
			                    args: { gift_id: data }
			                }
			        elsif alert.to_s.match(/opened your gift/)
			            payload = { alert: alert.to_s,
			                    title: 'ItsOnMe Gift Opened!',
			                    args: { gift_id: data }
			                }
			        elsif alert.to_s.match(/got the app/)
			            payload = { alert: alert.to_s,
			                    title: 'Thank You!',
			                    args: { gift_id: data }
			                }
			        else
			            payload = { alert: alert.to_s,
			                    title: 'New ItsOnMe Gift!',
			                    'action-loc-key': 'View Gift',
			                    args: { gift_id: data }
			                }
			        end
			    else
					payload =  { alert: alert.to_s }
			    end
			end
	        return payload
		end

	end

end



# SEND APNS push |186| - Amalia Burks sent you a gift at Commonwealth!
# 500 Internal PUSH FAILED - 841 - 186
# SEND APNS push |187| - Amalia Burks sent you a gift at Commonwealth!
# 500 Internal PUSH FAILED - 841 - 187
# SEND APNS push |191| - Amalia Burks sent you a gift at Commonwealth!
# 500 Internal PUSH FAILED - 841 - 191
# SEND APNS push |192| - Amalia Burks sent you a gift at Commonwealth!
# 500 Internal PUSH FAILED - 841 - 192
