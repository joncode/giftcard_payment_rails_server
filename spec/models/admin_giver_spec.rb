require 'spec_helper'

describe AdminGiver do

    it_should_behave_like "giver ducktype" do
        let(:object) { FactoryGirl.create(:admin_user).giver }
    end

    it "builds from factory" do
        admin_user  = FactoryGirl.create :admin_user
        admin_giver = admin_user.giver
        admin_giver.should be_valid
    end

    it "should get ID from :admin_user" do
        admin_user  = FactoryGirl.create :admin_user
        admin_giver = admin_user.giver
        admin_giver.id.should == admin_user.id
    end

    it "should respond to name with '#{SERVICE_NAME} Staff'" do
        admin_user  = FactoryGirl.create :admin_user
        admin_giver = admin_user.giver
        admin_giver.name.should == "#{SERVICE_NAME} Staff"
    end

    it "should respond to get_photo with cloud logo URL" do
        admin_user  = FactoryGirl.create :admin_user
        admin_giver = admin_user.giver
        admin_giver.get_photo.should == "http://res.cloudinary.com/drinkboard/image/upload/v1389818563/IOM-icon_round_bzokjj.jpg"
    end

    it "should associate with gift as giver" do
        provider    = FactoryGirl.create(:provider)
        admin_user  = FactoryGirl.create :admin_user
        admin_giver = admin_user.giver
        gift        = FactoryGirl.build(:gift)
        gift.giver  = admin_giver
        gift.save

        admin_giver.sent.first.id.should          == gift.id
        admin_giver.sent.first.class.should       == Gift
        admin_giver.sent.first.giver_name.should  == "#{SERVICE_NAME} Staff"
    end

    it "should associate with proto as giver" do
        provider    = FactoryGirl.create(:provider)
        admin_user  = FactoryGirl.create :admin_user
        admin_giver = admin_user.giver
        proto        = FactoryGirl.build(:proto)
        proto.giver  = admin_giver
        proto.giver_name = admin_giver.name
        proto.save

        admin_giver.protos.first.id.should          == proto.id
        admin_giver.protos.first.class.should       == Proto
        admin_giver.protos.first.giver_name.should  == "#{SERVICE_NAME} Staff"
    end

    it "should associate with Debts" do
        admin_user  = FactoryGirl.create :admin_user
        admin_giver = admin_user.giver
        debt = FactoryGirl.create(:debt, owner: admin_giver)
        admin_giver.debts.first.class.should == Debt
        admin_giver.debts.where(id: debt.id).count.should == 1
    end

    it "should create debt with cart total" do
        admin_user  = FactoryGirl.create :admin_user
        admin_giver = admin_user.giver
        debt = admin_giver.incur_debt("100.00")
        debt.amount.to_f.should == 100.0
        debt = admin_giver.incur_debt("131")
        debt.amount.to_f.should == 131.0
    end
end

























# == Schema Information
#
# Table name: at_users
#
#  id                     :integer         not null, primary key
#  first_name             :string(255)
#  last_name              :string(255)
#  email                  :string(255)
#  phone                  :string(255)
#  sex                    :string(255)
#  birthday               :date
#  password_digest        :string(255)
#  remember_token         :string(255)     not null
#  admin                  :boolean         default(FALSE)
#  code                   :string(255)
#  confirm                :integer         default(0)
#  reset_token_sent_at    :datetime
#  reset_token            :string(255)
#  active                 :boolean         default(TRUE)
#  db_user_id             :integer
#  address                :string(255)
#  city                   :string(255)
#  state                  :string(2)
#  zip                    :string(16)
#  photo                  :string(255)
#  min_photo              :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  last_login             :datetime
#  time_zone              :integer         default(0)
#  acct                   :boolean         default(FALSE)
#  encrypted_password     :string(255)     default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer         default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#

