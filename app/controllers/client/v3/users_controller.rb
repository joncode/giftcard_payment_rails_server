class Client::V3::UsersController < MetalController

    def index
        users = User.all.to_a
        success users.serialize_objs(:client)
        respond

    end






















end