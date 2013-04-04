class UpdateAttributesForAuthorizeCard < ActiveRecord::Migration
  def up
  	# remove gift default status of 'open' change to 'unpaid'
  	change_column_default(:gifts, :status, 'unpaid')
  	# make sale.response_string called response_json and make it .text
  	remove_column 	:sales, :response_string
  	add_column 		:sales, :resp_json, 		:text
  	# make sale.request same as above
  	remove_column 	:sales, :request_string
  	add_column 		:sales, :req_json, 			:text
  	# make response_code:integer store the code for queries
  	add_column 		:sales, :resp_code, 		:integer
  	# make response_text:string store the response
  	add_column 		:sales, :reason_text, 		:string
  	# add column for reason text
  	add_column 		:sales, :reason_code, 		:integer
  	# remove sale.status
  	remove_column 	:sales, :status

  end

  def down
  	change_column_default(:gifts, :status, 'open')
  	add_column 		:sales, :response_string, 	:string
  	remove_column 	:sales, :resp_json
  	add_column 		:sales, :request_string, 	:string 	
  	remove_column 	:sales, :req_json
  	remove_column 	:sales, :resp_code
  	remove_column 	:sales, :reason_text
  	remove_column 	:sales, :reason_code
  	add_column 		:sales, :status, 			:string
  end
end
