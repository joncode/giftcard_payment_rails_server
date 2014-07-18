module GenericPayableDucktype
    extend ActiveSupport::Concern

    def success?
        if self.payable_type == 'Sale'
            self.payable.success?
        else
            resp_code == 1
        end
    end

    def resp_code
        if self.payable_type == 'Sale'
            self.payable.resp_code
        else
            self.id ? 1 : 3
        end
    end

    def reason_text
        if self.payable_type == 'Sale'
            self.payable.reason_text
        else
            if self.id
                "Transaction approved."
            else
                self.errors.full_messages
            end
        end
    end

    def reason_code
        if self.payable_type == 'Sale'
            self.payable.reason_code
        else
            self.id ? 1 : 2
        end
    end

end