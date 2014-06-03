class Client::V3::SessionsController < MetalController

    def create
    	login = params["data"]
    	email = login["email"]
    	password = login["password"]
    	pn_token = login["pn_token"]
    	user = User.find_by(email: email)
    	user.authenticate(password)
    	success user.client_serialize 
    	respond
    end






















end