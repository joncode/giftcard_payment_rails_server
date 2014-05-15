class Client::V3::ClientsController < JsonController



    def cities
        success CITY_LIST
        respond
    end





















end