require 'spec_helper'


describe NewGiftReportClass do


    # making a new gift report class
    # testing it with a special gift factory of all gifts that knows its own total retail value


    it "should display total retail value of gifts" do

        provider = FactoryGirl.create(:provider)
        SpecialGiftFactory.create_all_gifts_in_test_db(provider)
        actual_retail_price = SpecialGiftFactory.actual_retail_price

        calc_retail_value =  NewGiftReportClass.retail_value
        calc_retail_value.should == actual_retail_price

    end





end


# what is SpecialGiftFactory
# factory of all gifts that knows its own total retail values , costs , fees
# what are the gifts
# all 5 origin gifts
# each possible status combo of all 5 origin gifts
# regifts of all regiftable of above gifts
# all possible status's of those regifts
# regifts of all possible fo those

# 5 origin gift.cat = [ 0 , 200 , 210 , 300 , 310 ]
# 7 status's  [ cancel ,incomplete , open , notified , redeemed , expired , regifted ]

# creation hashes for each kind of gift

# 5 re-gift.cat =

    # -------- current
# 0   - sale
# 100 - regift of sale
# 110 - regift of gift_admin
# 120 - regift of gift_promo
# 130 - regift of gift_campaign from Merchant Themselves
# 131 - regift of gift campaign from ItsOnMe

# 200 - gift_promo
# 210 - gift_admin
# 300 - gift campaign from Merchant themselves
# 310 - gift_campaign from ItsOnMe


    # -------- refactor
# 100 - sale
# 110 - regift of sale
# 310 - regift of gift_admin
# 210 - regift of gift_promo
# 410 - regift of gift_campaign from Merchant Themselves
# 510 - regift of gift_campaign from ItsOnMe

# 200 - gift_promo
# 300 - gift_admin
# 400 - gift campaign from Merchant themselves
# 500 - gift_campaign from ItsOnMe


