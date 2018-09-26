
if Rails.env.production? || Rails.env.development?
	APNS.host = "gateway.push.apple.com"
	APNS.pem = File.join(Rails.root, "config/certs/aps-9-26-2018-PROD.pem")
end
if Rails.env.staging?
	APNS.host = "gateway.push.apple.com"
	APNS.pem = File.join(Rails.root, "config/certs/aps-9-26-2018-QA.pem")
end
# if Rails.env.development?
# 	APNS.host = "gateway.sandbox.push.apple.com"
# 	APNS.pem = File.join(Rails.root, "config/certs/QApushcert.pem")
# end