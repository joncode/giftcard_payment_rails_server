module DbRemoval
    extend ActiveSupport::Concern

    def total
        raise NotImplementedError
    end

    def tax
        raise NotImplementedError
    end

    def tip
        raise NotImplementedError
    end

    def regift_id
        raise NotImplementedError
    end

    def foursquare_id
        raise NotImplementedError
    end

    def sale_id
        raise NotImplementedError
    end

    def pay_type
        raise NotImplementedError
    end

    def pay_id
        raise NotImplementedError
    end

    def cat
        raise NotImplementedError
    end

    def total= amount
        raise NotImplementedError
    end

    def tax= amount
        raise NotImplementedError
    end

    def tip= amount
        raise NotImplementedError
    end

    def regift_id= amount
        raise NotImplementedError
    end

    def foursquare_id= amount
        raise NotImplementedError
    end

    def sale_id= amount
        raise NotImplementedError
    end

    def pay_type= amount
        raise NotImplementedError
    end

    def pay_id= amount
        raise NotImplementedError
    end

    def cat= amount
        raise NotImplementedError
    end
end