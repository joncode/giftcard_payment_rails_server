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

        it "should respond to :payment" do
            u.affiliate = a
            r = Register.create(gift_id: 10, amount: 1140, partner: a, origin: :aff_user, type_of: :debt, affiliation: u.affiliation)
            p = Payment.new(u_transactions: 1, u_amount: 1140, total: 1140, partner: a)
            p.id.should be_nil
            r.payment   = p
            r.save
            r.reload
            r.payment_id.should == p.id
            r.payment.should    == p
            p2                  = Payment.last
            p2.id.should        == p.id
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

    it "should not save without a partner" do
        r = FactoryGirl.build(:register)
        r.partner_id = nil
        r.save
        r.should have_at_least(1).error_on(:partner_id)
        r = nil
        r = FactoryGirl.build(:register)
        r.partner_type = nil
        r.save
        r.should have_at_least(1).error_on(:partner_type)
    end

    it "builds from factory" do
        affiliate = FactoryGirl.build :register
        affiliate.should be_valid
    end
end
# == Schema Information
#
# Table name: registers
#
#  id           :integer         not null, primary key
#  gift_id      :integer
#  amount       :integer
#  partner_id   :integer
#  partner_type :string(255)
#  origin       :integer         default(0)
#  type_of      :integer         default(0)
#  created_at   :datetime
#  updated_at   :datetime
#

