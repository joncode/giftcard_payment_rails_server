class OpsFirstData
	extend MoneyHelper
	class << self

		def parse_response r, data=nil
			ary = r.message.split(' - ')
			msg = ary[1].present? ? ary[1] : ary[0]
			hsh = { message: msg }
			hsh[:status] = r.success? ? 1 : 0
			hsh[:data] = data if data.present?
			hsh
		end

	    def gateway_hash_response r
	        hsh = {}
	        hsh["transaction_id"]  = r.params['authorization_num']
	        hsh["resp_json"]       = r.to_json
	        hsh["req_json"]        = r.params["ctr"].to_json
	        hsh["resp_code"]       = 1
	        hsh["reason_text"]     = r.message
	        hsh["reason_code"]     = 1
	        hsh["revenue"]         = r.params['dollar_amount']
	        hsh
	    end

#	-------------

		def purchase token, amount
			# amount is in cents
			if amount.kind_of?(String)
				amount = currency_to_cents(amount)
			end
			puts "\n OpsFirstData.purchase Here is the amount - should be in cents #{amount.to_s} - #{token.inspect}"
			r = gateway.purchase amount, token
			if r.success?
				gateway_hash_response r
			else
				parse_response r, JSON.parse(r.to_json)
			end
		end

		def refund token, amount
			r = gateway.refund amount, token
			parse_response r, JSON.parse(r.to_json)
		end

		def authorize token, amount
			r = gateway.authorize amount, token
			parse_response r, JSON.parse(r.to_json)
		end

#	-------------

		def tokenize card_hsh
			credit_card = ActiveMerchant::Billing::CreditCard.new(
				:first_name => card_hsh["first_name"],
				:last_name => card_hsh["last_name"],
				:number => card_hsh["number"],
				:month => card_hsh["month"],
				:year => card_hsh["year"] ,
				:verification_value => card_hsh["cvv"]
			)
			result = gateway.store(credit_card)
			if result.success?
				parse_response result, result.authorization
			else
				parse_response result, JSON.parse(result.to_json)
			end
		end

#	-------------

		def gateway
			@gateway ||= new_gateway
		end

		def new_gateway
			gateway = ActiveMerchant::Billing::FirstdataE4Gateway.new({
				login: FIRST_DATA_LOGIN_CAD,
				password: FIRST_DATA_PASSWORD_CAD
			})
			gateway.default_currency = 'CAD'
			gateway
		end

	end

end


#### SUCCESS
# exact_id = SC9794-68
# password =
# transaction_type = 00
# dollar_amount = 0.1
# surcharge_amount =
# transaction_tag = 84446402
# track1 =
# track2 =
# pan =
# authorization_num = ET160551
# card_holders_name = Tester VisaCard
# verification_str1 =
# cvd_presence_ind = 0
# zip_code =
# tax1_amount =
# tax1_number =
# tax2_amount =
# tax2_number =
# secure_auth_required =
# secure_auth_result =
# ecommerce_flag =
# xid =
# cavv =
# cavv_algorithm =
# reference_no =
# customer_ref =
# reference_3 =
# language =
# client_ip =
# client_email =
# user_name =
# transaction_error = false
# transaction_approved = true
# exact_resp_code = 00
# exact_message = Transaction Normal - Approved
# bank_resp_code = 100
# bank_message = Approved
# bank_resp_code_2 =
# sequence_no = 000018
# avs =
# cvv2 = I
# retrieval_ref_no = 1693333
# cavv_response = A
# currency = CAD
# amount_requested =
# partial_redemption = false
# merchant_name = ItsOnMe DEMO0693
# merchant_address =
# merchant_city =
# merchant_province = Alabama
# merchant_country = United States
# merchant_postal =
# merchant_url =
# transarmor_token = 0643182188931111
# card_type = Visa
# current_balance =
# previous_balance =
# ean =
# card_cost =
# virtual_card = false
# ctr = ========== TRANSACTION RECORD ==========
# ItsOnMe DEMO0693

# , AL
# United States


# TYPE: Purchase

# ACCT: Visa                    $ 0.10 CAD

# CARDHOLDER NAME : Tester VisaCard
# CARD NUMBER     : ############1111
# DATE/TIME       : 27 May 16 20:57:06
# REFERENCE #     : 02 000018 T
# AUTHOR. #       : ET160551
# TRANS. REF.     :

#     Approved - Thank You 100


# Please retain this copy for your records.

# Cardholder will pay above amount to
# card issuer pursuant to cardholder
# agreement.
# ========================================



### FAILED

# transaction_approved = true
# error_number =
# error_description =
# ecommerce_error_code =









