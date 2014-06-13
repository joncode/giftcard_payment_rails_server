class Client::V3::UsersController < MetalController

    def index
    	puts "\n FAEK TOke = #{request.headers["HTTP_X_AUTH_TOKEN"]} \n"
        users = User.all.to_a
        success users.serialize_objs(:client)
        respond

    end






















end