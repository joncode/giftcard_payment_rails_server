class EpsonPrinter < ActiveRecord::Base
    belongs_to :client


    def initialize(client=nil)
        if client.is_a? Client
            self.client_id       = client.id
            self.application_key = client.application_key
        end
    end

end
