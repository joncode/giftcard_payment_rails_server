class UpdateAttributesForAuthorizeCard < ActiveRecord::Migration
  def up
  	# remove gift default status of 'open' change to 'unpaid'
  	# make sale.response_string called response_json and make it .text
  	# make sale.request same as above
  	# make response_code:integer store the code for queries
  	# make response_text:string store the response
  	# remove sale.status
  end

  def down
  end
end
