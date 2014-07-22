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
            1
        end
    end

    def reason_text
        if self.payable_type == 'Sale'
            self.payable.reason_text
        else
            "This transaction has been approved."
        end
    end

    def reason_code
        if self.payable_type == 'Sale'
            self.payable.reason_code
        else
            1
        end
    end

end