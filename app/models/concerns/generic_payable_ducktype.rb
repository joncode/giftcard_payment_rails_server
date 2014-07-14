module GenericPayableDucktype
    extend ActiveSupport::Concern

    def success?
        resp_code == 1
    end

    def resp_code
        self.id ? 1 : 3
    end

    def reason_text
        if self.id
            "Transaction approved."
        else
            self.errors.full_messages
        end
    end

    def reason_code
        self.id ? 1 : 2
    end



end