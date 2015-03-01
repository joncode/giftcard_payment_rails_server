require 'spec_helper'

describe Payment do

    context 'associations' do

        it "should respond to :partner" do
            p = FactoryGirl.create(:payment)
            a = FactoryGirl.create(:affiliate)
            p.partner = a
            p.partner.should == a
        end

        it "should respond to :affiliate" do
            p = FactoryGirl.create(:payment)
            a = FactoryGirl.create(:affiliate)
            p.partner = a
            p.affiliate.should == a
        end

        it "should respond to registers" do
            u = FactoryGirl.create(:user)
            a = FactoryGirl.create(:affiliate)
            u.affiliate = a
            r = Register.create(gift_id: 10, amount: 1140, partner: a, origin: :aff_user, type_of: :debt, affiliation: u.affiliation)
            p = Payment.new(u_transactions: 1, u_amount: 1140, total: 1140, partner: a)
            p.registers << r
            p.registers.should  == [r]
            r.payment_id.should == p.id
        end
    end

    it "builds from factory" do
        payment = FactoryGirl.create :payment
        payment.should be_valid
    end
end
# == Schema Information
#
# Table name: payments
#
#  id             :integer         not null, primary key
#  start_date     :datetime
#  end_date       :datetime
#  auth_date      :datetime
#  conf_num       :string(255)
#  m_transactions :integer
#  m_amount       :integer
#  u_transactions :integer
#  u_amount       :integer
#  total          :integer
#  paid           :boolean
#  partner_id     :integer
#  partner_type   :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#

