
if Rails.env.production? || Rails.env.development?
	APNS.host = "gateway.push.apple.com"
	APNS.pem = File.join(Rails.root, "config/certs/aps-8-28-2017.pem")
end
if Rails.env.staging?
	APNS.host = "gateway.push.apple.com"
	APNS.pem = File.join(Rails.root, "config/certs/aps-8-28-2017-QA.pem")
end
# if Rails.env.development?
# 	APNS.host = "gateway.sandbox.push.apple.com"
# 	APNS.pem = File.join(Rails.root, "config/certs/QApushcert.pem")
# end