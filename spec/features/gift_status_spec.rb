require 'spec_helper'

describe "Sale" do

        # HOW TO MAKE EACH KIND
        #     cancel_nil_nil
        #         Sale    - gift created by Sale unsuccessful - declined, duplicate, cancelled
        #     incomplete_nil_live
        #         :all    - to out of network receiver
        #     notified_open_live
        #         :all    - in network receiver - receiver joins network
        #     notified_notified_live
        #         :all    - receiver clicks on gift in-client
        #     complete_redeemed_redeemed
        #         :all    - receiver clicks on redeem in-client
        #     complete_regifted_nil
        #         :all    - receiver regifts in-client

        # HOW TO MAKE EACH PAY STAT
        #     refund_cancel_cancel
        #         Sale    - :admt refunds and cancels the gift
        #     refund_comp_comp
        #         Sale    - :admt refund(both-comp)
        #     refund_settled_comp
        #         Sale    - :admt refund db only - admt paid gift
        #     refund_unpaid_comp
        #         Sale    - :admt refund db only - amdt hasnt paid gift yet
        #     refund_comp_settled
        #         Sale    - :admt refund merchant - db settled
        #     charge_unpaid_settled
        #         Sale    - Sale successful - :admt not paid merchant yet
        #     charge_settled_settled
        #         Sale    - :admt has paid merchant
        #     unpaid_unpaid_unpaid
        #         Sale    - card charge not successful
        #     charge_regifted_regifted
        #         gift has been regifted

    describe "failed credit card" do
        #     cancel_nil_nil & unpaid_unpaid_unpaid
        #         create gift - credit card denied
        #         create gift - credit card duplicate transaction
    end

    describe "normal path" do
        #     incomplete_nil_live & charge_unpaid_settled
        #         create gift - sale good - user not in network
        #     notified_open_live
        #         sign new user into system
        #     notified_notified_live
        #         user opens gift
        #     complete_redeemed_redeemed
        #         user redeems gift
        #     charge_settled_settled
        #         admt pay merchant for gift
    end

    describe "regift" do
        #     notified_open_live & charge_unpaid_settled
        #         create gift - sale good - user not in network
        #     notified_notified_live
        #         user opens gift
        #     complete_regifted_nil
        #         user regifts gift to another user - transfers the pay_stat
    end

    describe "gift refunded / gift cancelled" do
        #     notified_open_live & charge_unpaid_settled
        #         create gift - sale good - user not in network
        #     refund_cancel_nil & refund_cancel_cancel
        #         admt refund cancels the gift
    end

    describe "gift refunded db-comp / gift live" do
        #     incomplete_nil_live & charge_unpaid_settled
        #         create gift - sale good - user not in network
        #     refund_nil_live & refund_unpaid_comp
        #         admt refund just db leaves it live
        #     refund_open_live
        #         user opens gift
        #     refund_notified_live
        #         user notifies provider
        #     refund_redeemed_redeemed
        #         user redeem gift
        #     refund_settled_comp
        #         admt pays merchant
    end

    describe "gift refunded merch-comp / gift live" do
        #     notified_open_live & charge_unpaid_settled
        #         create gift - sale good - user not in network
        #     refund_comp_settled
        #         admt refunds against merchant , db gets paid
    end

    describe "gift refunded both-comp / gift live" do
        #     notified_open_live & charge_unpaid_settled
        #         create gift - sale good - user not in network
        #     refund_comp_comp
        #         admt refunds against both
    end

end

describe "Promo" do

        # HOW TO MAKE EACH KIND
        #     incomplete_nil_live
        #         :all    - to out of network receiver
        #     notified_open_live
        #         :all    - in network receiver - receiver joins network
        #     notified_notified_live
        #         :all    - receiver clicks on gift in-client
        #     complete_redeemed_redeemed
        #         :all    - receiver clicks on redeem in-client
        #     expired_expired_expired
        #         Promo   - cron to expire gift ?

        # HOW TO MAKE EACH PAY STAT
        #     charge_settled_settled
        #         Promo   - :admt has settled debt against merchant revenues
        #     charge_settled_unpaid
        #         Promo   - :admt has NOT settled debt against merchant revenues
        #     refund_expired_nil
        #         Promo   - gift has expired , merchant is refunded

    describe "normal path" do
        #     incomplete_nil_live & charge_settled_unpaid
        #         create gift - sale good - user not in network
        #     notified_open_live
        #         sign new user into system
        #     notified_notified_live
        #         user opens gift
        #     complete_redeemed_redeemed
        #         user redeems gift
        #     charge_settled_settled
        #         admt pay merchant for gift
    end

    describe "gift expires" do
        #     notified_open_live & charge_settled_unpaid
        #         create gift - sale good - user not in network
        #     expired_expired_expired & refund_expired_nil
        #         Promo   - cron to expire gift ?
    end

end

describe "Regift" do

        # HOW TO MAKE EACH KIND
        #     incomplete_nil_live
        #         :all    - to out of network receiver
        #     notified_open_live
        #         :all    - in network receiver - receiver joins network
        #     notified_notified_live
        #         :all    - receiver clicks on gift in-client
        #     complete_redeemed_redeemed
        #         :all    - receiver clicks on redeem in-client
        #     complete_regifted_nil
        #         :all    - receiver regifts in-client

        # HOW TO MAKE EACH PAY STAT
        #     refund_cancel_cancel
        #         Regift  - :admt cancels the gift
        #     refund_comp_comp
        #         Regift  -
        #     refund_settled_comp
        #         Regift  -
        #     refund_unpaid_comp
        #         Regift  -
        #     refund_comp_settled
        #         Regift  -
        #     charge_unpaid_settled
        #         Regift  - a sold gift is original parent in regift chain
        #     charge_settled_settled
        #         Regift  - :admt has paid merchant
        #

    describe "normal path" do
        #     incomplete_nil_live  && charge_unpaid_settled
        #         regift a gift ou of network
        #     notified_open_live
        #         :all    - in network receiver - receiver joins network
        #     notified_notified_live
        #         :all    - receiver clicks on gift in-client
        #     complete_redeemed_redeemed
        #         :all    - receiver clicks on redeem in-client
        #     charge_settled_settled
        #         :amdt pays the merchant
    end

    describe "gift refunded db-comp / gift live" do
        #     notified_open_live & charge_unpaid_settled
        #         regift a gift in network
        #     refund_unpaid_comp
        #         :amdt refunds the gift admin-comp
        #     notified_notified_live
        #         :all    - receiver clicks on gift in-client
        #     complete_redeemed_redeemed
        #         :all    - receiver clicks on redeem in-client
        #     refund_settled_comp
        #         :admt pays the merchant
    end

    describe "gift refunded merch-comp / gift live" do
        #     notified_open_live & charge_unpaid_settled
        #         regift a gift in network
        #     refund_comp_settled
        #         :amdt refunds the gift merchant-comp
    end

    describe "gift refunded both-comp / gift live" do
        #     notified_open_live & charge_unpaid_settled
        #         regift a gift in network
        #     refund_comp_comp
        #         :amdt refunds the gift both-comp
    end

    describe "gift refunded / gift cancelled" do
        #     notified_open_live & charge_unpaid_settled
        #         create gift - sale good - user not in network
        #     refund_cancel_nil & refund_cancel_cancel
        #         admt refund cancels the gift
    end

end