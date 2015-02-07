require 'spec_helper'

include GiftModelFactory

describe Register do

    context 'associations' do

        let(:u) { FactoryGirl.create(:user) }
        let(:a) { FactoryGirl.create(:affiliate)}

        it "should respond to :partner" do
            p = FactoryGirl.create(:register)
            p.partner = a
            p.partner.should == a
        end

        it "should update and autosave affiliation payout" do
            u.affiliate = a

            Register.create(gift_id: 10, amount: 1140, partner_type: a.class.to_s, partner_id: a.id, origin: :aff_user, type_of: :debt, affiliation: u.affiliation)
            a.reload
            a.payout_users.should == 1140
            u.affiliation.payout.should == 1140
        end

        it "should update and autosave affiliate payout aff_user" do
            u.affiliate = a
            Register.create(gift_id: 10, amount: 1140, partner: a, origin: :aff_user, type_of: :debt, affiliation: u.affiliation)
            a.reload
            a.payout_users.should == 1140
        end

        it "should update and autosave affiliate payout aff_loc" do
            u.affiliate = a
            Register.create(gift_id: 10, amount: 1140, partner: a, origin: :aff_loc, type_of: :debt, affiliation: u.affiliation)
            a.reload
            a.payout_merchants.should == 1140
        end
    end

    it "builds from factory" do
        affiliate = FactoryGirl.create :register
        affiliate.should be_valid
    end
end
