module GiftConsole

    def makeg g
        newg = Gift.new
        newg.giver_id = g.giver_id
        newg.receiver_name = g.receiver_name
        newg.provider_id = g.provider_id
        newg.total = g.total
        newg.service = g.service
        newg.credit_card = g.credit_card
        newg.shoppingCart = g.shoppingCart
        newg
    end

    def ginit
        l = Gift.last
        makeg l
    end

    def makes g, sale=nil
        s = Sale.new
        sale = Sale.last if sale.nil?
        s.card_id = g.credit_card
        s.provider_id = g.provider_id
        s.giver_id = g.giver_id
        s.transaction_id = sale.transaction_id
        s.revenue = sale.revenue
        s.resp_json = sale.resp_json
        s.req_json = sale.req_json
        s.resp_code = sale.resp_code
        s.reason_text = sale.reason_text
        s.reason_code = sale.reason_code
        s.response    = sale.response
        s
    end


end