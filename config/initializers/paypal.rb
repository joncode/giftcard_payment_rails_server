require 'paypal-sdk-rest'
include PayPal::SDK::REST
# PayPal::SDK.load("config/paypal.yml", Rails.env)
# PayPal::SDK.logger = Rails.logger



PAYPAL_CLIENT_ID = 'AadDfRv2dU0vrF2ul8h2NSUsf1PpqAATEo-7rH8bTVHBNUIrCeA2ImOV2GPnQoIWUK9ZAH01Ay7AiYqR'
PAYPAL_SECRET = 'EO_pC_xrbSIx3VYaOdIPjazXqT0QlazIiAY_meiqXYNjUkfvsI08W2gP3zYbzm8-KvVbZGW0bSgmIm0u'


# PAY = PayPal::SDK.configure(
#   :mode => "sandbox", # "sandbox" or "live"
#   :client_id => PAYPAL_CLIENT_ID,
#   :client_secret => PAYPAL_SECRET,
#   :ssl_options => { } )


# CC = CreditCard.new({
# :type => "visa",
# :number => "4446283280247004",
# :expire_month => "11",
# :expire_year => "2018",
# :first_name => "Joe",
# :last_name => "Shopper" })


# CCA = CreditCard.new({
#    # ###CreditCard
#    # A resource representing a credit card that can be
#    # used to fund a payment.
#    :type => "visa",
#    :number => "4567516310777851",
#    :expire_month => "11",
#    :expire_year => "2018",
#    :cvv2 => "874",
#    :first_name => "Joe",
#    :last_name => "Shopper",

#     # ###Address
#     # Base Address object used as shipping or billing
#     # address in a payment. [Optional]
#    :billing_address => {
#      :line1 => "52 N Main ST",
#      :city => "Johnstown",
#      :state => "OH",
#      :postal_code => "1121",
#      :country_code => "US" }})



# @payment.create