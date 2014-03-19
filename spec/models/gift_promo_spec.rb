require 'spec_helper'

describe GiftPromo do

    before(:each) do
        Provider.delete_all
        @provider = FactoryGirl.create(:provider)
        @gift_hsh = {}
        @gift_hsh["message"]        = "here is the promo gift"
        @gift_hsh["receiver_name"]  = "Customer Name"
        @gift_hsh["receiver_email"] = "customer@gmail.com"
        @gift_hsh["provider_id"]    = @provider.id
        @gift_hsh["provider_name"]  = @provider.name
        @gift_hsh["shoppingCart"]   = "[{\"price\":\"10\",\"quantity\":3,\"section\":\"beer\",\"item_id\":782,\"item_name\":\"Budwesier\"}]"
    end

    it_should_behave_like "gift serializer" do
        let(:gift) { GiftPromo.create(@gift_hsh) }
    end

    it "should create gift" do

        gift_promo = GiftPromo.create(@gift_hsh)
        gift_promo.class.should    == GiftPromo
        gift_promo.message.should        == @gift_hsh["message"]
        gift_promo.receiver_name.should  == "Customer Name"
        gift_promo.receiver_email.should == "customer@gmail.com"
        gift_promo.provider_id.should    == @provider.id
        gift_promo.provider_name.should  == @provider.name
        gift = Gift.find(gift_promo.id)
        gift.class.should          == Gift
        gift.message.should        == @gift_hsh["message"]
        gift.receiver_name.should  == "Customer Name"
        gift.receiver_email.should == "customer@gmail.com"
        gift.provider_id.should    == @provider.id
        gift.provider_name.should  == @provider.name
    end

    it "should not run add provider if it has provider ID and name" do
        Gift.any_instance.should_not_receive(:add_provider_name)
        gift_promo = GiftPromo.create @gift_hsh
    end

    it "should add the provider name to the gift" do
        @gift_hsh.delete("provider_name")
        Gift.any_instance.should_receive(:add_provider_name)
        gift_promo = GiftPromo.create @gift_hsh
    end

    it "should set the giver info to the BizUser" do
        biz_user = BizUser.find(@provider.id)
        gift = GiftPromo.create @gift_hsh
        gift.reload
        gift.giver_id.should   == biz_user.id
        gift.giver_name.should == biz_user.name
        gift.giver.should      == biz_user
        gift.giver_type.should == biz_user.class.to_s
    end

    it "should create a Debt for the BizUser and associate" do
        gift = GiftPromo.create @gift_hsh
        gift.reload
        gift.value.should           == "30"
        gift.payable.owner.should   == @provider.biz_user
        gift.payable.amount.should  == BigDecimal("4.50")
    end

    it "should calculate the correct value from the shoppingCart" do
        @gift_hsh.delete("value")
        gift = GiftPromo.create @gift_hsh
        gift.reload
        gift.value.should           == "30"
        gift.payable.owner.should   == @provider.biz_user
        gift.payable.amount.should  == BigDecimal("4.50")
    end

    it "should set the cost correctly" do
        gift = GiftPromo.create @gift_hsh
        gift.reload
        gift.value.should           == "30"
        gift.cost.should            == "0.0"
    end

    it "should set the cat to 200" do
        gift = GiftPromo.create @gift_hsh
        gift.reload
        gift.cat.should           == 200
    end

    xit "should set the expiration date" do

    end

end# == Schema Information
#
# Table name: gifts
#
#  id             :integer         not null, primary key
#  giver_name     :string(255)
#  receiver_name  :string(255)
#  provider_name  :string(255)
#  giver_id       :integer
#  receiver_id    :integer
#  total          :string(20)
#  credit_card    :string(100)
#  provider_id    :integer
#  message        :text
#  status         :string(255)     default("unpaid")
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#  receiver_phone :string(255)
#  tax            :string(255)
#  tip            :string(255)
#  regift_id      :integer
#  foursquare_id  :string(255)
#  facebook_id    :string(255)
#  anon_id        :integer
#  sale_id        :integer
#  receiver_email :string(255)
#  shoppingCart   :text
#  twitter        :string(255)
#  service        :string(255)
#  order_num      :string(255)
#  cat            :integer         default(0)
#  active         :boolean         default(TRUE)
#  pay_stat       :string(255)
#  pay_type       :string(255)
#  pay_id         :integer
#  redeemed_at    :datetime
#  server         :string(255)
#  payable_id     :integer
#  payable_type   :string(255)
#  giver_type     :string(255)
#  value          :string(255)
#  expires_at     :datetime
#  refund_id      :integer
#  refund_type    :string(255)
#

# == Schema Information
#
# Table name: gifts
#
#  id             :integer         not null, primary key
#  giver_name     :string(255)
#  receiver_name  :string(255)
#  provider_name  :string(255)
#  giver_id       :integer
#  receiver_id    :integer
#  total          :string(20)
#  credit_card    :string(100)
#  provider_id    :integer
#  message        :text
#  status         :string(255)     default("unpaid")
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#  receiver_phone :string(255)
#  facebook_id    :string(255)
#  anon_id        :integer
#  receiver_email :string(255)
#  shoppingCart   :text
#  twitter        :string(255)
#  service        :string(255)
#  order_num      :string(255)
#  cat            :integer         default(0)
#  active         :boolean         default(TRUE)
#  pay_stat       :string(255)
#  redeemed_at    :datetime
#  server         :string(255)
#  payable_id     :integer
#  payable_type   :string(255)
#  giver_type     :string(255)
#  value          :string(255)
#  expires_at     :datetime
#  refund_id      :integer
#  refund_type    :string(255)
#  cost           :string(255)
#

