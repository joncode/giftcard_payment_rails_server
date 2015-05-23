module GiftModelFactory

	def make_gift_sale(giver, receiver, value, provider_id)
        card     = FactoryGirl.create(:card, name: giver.name, user_id: giver.id)
        auth_response = "1,1,1,This transaction has been approved.,JVT36N,Y,2202633834,,,47.25,CC,auth_capture,,#{card.first_name},#{card.last_name},,,,,,,,,,,,,,,,,"
        stub_request(:post, "https://test.authorize.net/gateway/transact.dll").to_return(:status => 200, :body => auth_response, :headers => {})

        gift_hsh = {}
        gift_hsh["message"]        = "I just Bought a Gift!"
        gift_hsh["receiver_name"]  = receiver.name
        gift_hsh["receiver_id"]    = receiver.id
        gift_hsh["provider_id"]    = provider_id
        gift_hsh["giver"]          = giver
        gift_hsh["value"]          = value
        gift_hsh["service"]        = "2.25"
        gift_hsh["credit_card"]    = card.id
        gift_hsh["shoppingCart"]   = "[{\"price\":\"10\",\"quantity\":3,\"section\":\"beer\",\"item_id\":782,\"item_name\":\"Budwesier\"}]"
        gift_sale = GiftSale.create gift_hsh

        gift = Gift.find gift_sale.id
        gift.update(status: 'open') if gift.status == 'unpaid'
        gift
    end

    def regift_gift(gift)
        if gift.status == 'open'
            gift.notify
        end

        gift_hsh = {}
        gift_hsh["message"]       = "I just REGIFTED!"
        gift_hsh["name"]          = gift.receiver.name
        gift_hsh["receiver_id"]   = gift.giver_id
        gift_hsh["giver"]         = gift.receiver
        gift_hsh["old_gift_id"]   = gift.id
        gift_regift = GiftRegift.create(gift_hsh)

        gift = Gift.find gift_regift.id
        gift.update(status: 'open') if gift.status == 'unpaid'
        gift
    end
end