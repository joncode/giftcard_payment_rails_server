class OpsPushApple

	class << self

		def send_push(pnt, alert)

	        puts "SEND APNS push |#{pnt.id}| - #{alert}"

	        payload = format_payload(alert)
	        n = APNS::Notification.new(pnt.pn_token, payload)
	        APNS.send_notifications([n])

		end

		def format_payload alert
	        if alert.to_s.match(/has been delivered/)
	            payload = { body: alert,
	                    title: 'ItsOnMe Gift Delivered!',
	                    args: { gift_id: gift_id }
	                }
	        elsif alert.to_s.match(/opened your gift/)
	            payload = { body: alert,
	                    title: 'ItsOnMe Gift Opened!',
	                    args: { gift_id: gift_id }
	                }
	        elsif alert.to_s.match(/got the app/)
	            payload = { body: alert,
	                    title: 'Thank You!',
	                    args: { gift_id: gift_id }
	                }
	        else
	            payload = { body: alert,
	                    title: 'New ItsOnMe Gift!',
	                    'action-loc-key': 'View Gift',
	                    args: { gift_id: gift_id }
	                }
	        end
	        return payload
		end

	end

end


