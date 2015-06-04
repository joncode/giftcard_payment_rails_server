require 'spec_helper'

describe Merchant do

	context "associations" do

        it "should respond to :affiliate" do
            u = FactoryGirl.create(:merchant)
            a = FactoryGirl.create(:affiliate)
            u.affiliate = a
            u.affiliate.should == a
        end

        it "should respond to :affiliations" do
        	m = FactoryGirl.create(:merchant)
            a = FactoryGirl.create(:affiliation)
            m.affiliation = a
            m.affiliation.should == a
        end
	end
end
# == Schema Information
#
# Table name: merchants
#
#  id               :integer         not null, primary key
#  name             :string(255)
#  token            :string(255)
#  zinger           :string(255)
#  description      :text
#  active           :boolean         default(TRUE)
#  address          :string(255)
#  address_2        :string(255)
#  city             :string(50)
#  state            :string(2)
#  zip              :string(16)
#  phone            :string(20)
#  email            :string(255)
#  website          :string(255)
#  facebook         :string(255)
#  twitter          :string(255)
#  photo            :string(255)
#  photo_l          :string(255)
#  rate             :decimal(, )     default(85.0)
#  sales_tax        :decimal(8, 3)
#  setup            :string(255)     default("000010")
#  image            :string(255)
#  pos              :boolean         default(FALSE)
#  tou              :boolean         default(FALSE)
#  tz               :integer         default(0)
#  live             :boolean         default(FALSE)
#  paused           :boolean         default(TRUE)
#  latitude         :float
#  longitude        :float
#  ein              :string(255)
#  region_id        :integer
#  pos_merchant_id  :string(255)
#  account_admin_id :integer
#  ftmeta           :tsvector
#  r_sys            :integer         default(2)
#  created_at       :datetime
#  updated_at       :datetime
#  affiliate_id     :integer
#  payment_event    :integer         default(0)
#  tender_type_id   :string(255)
#  pos_sys          :string(255)
#  prime_amount     :integer
#  prime_date       :date
#  contract_date    :date
#  signup_email     :string(255)
#  signup_name      :string(255)
#

