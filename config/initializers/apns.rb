
if Rails.env.production? || Rails.env.development?
	APNS.host = "gateway.push.apple.com"
	APNS.pem = File.join(Rails.root, "config/certs/PRODpushcert.pem")
end
if Rails.env.staging?
	APNS.host = "gateway.sandbox.push.apple.com"
	APNS.pem = File.join(Rails.root, "config/certs/QApushcert.pem")
end
# if Rails.env.development?
# 	APNS.host = "gateway.sandbox.push.apple.com"
# 	APNS.pem = File.join(Rails.root, "config/certs/QApushcert.pem")
# end