require 'spec_helper'
require 'json_helper'

describe Card do

	context :validations do

        it "requires cim_token" do
          card = FactoryGirl.build(:card_token, :cim_token => nil)
          card.should_not be_valid
          card.should have_at_least(1).error_on(:cim_token)
        end

        it "requires nickname" do
          card = FactoryGirl.build(:card_token, :nickname => nil)
          card.should_not be_valid
          card.should have_at_least(1).error_on(:nickname)
        end

        it "requires user_id" do
          card = FactoryGirl.build(:card_token, :user_id => nil)
          card.should_not be_valid
          card.should have_at_least(1).error_on(:user_id)
        end

        it "requires brand" do
          card = FactoryGirl.build(:card_token, :brand => nil)
          card.should_not be_valid
          card.should have_at_least(1).error_on(:brand)
        end

        it "requires last_four" do
          card = FactoryGirl.build(:card_token, :last_four => nil)
          card.should_not be_valid
          card.should have_at_least(1).error_on(:last_four)
        end

	end

	context "gift sale process - card methods used" do

		it "should respond to card.create_card_hsh" do
			user = FactoryGirl.create(:user, cim_profile: "7825348")
			hsh = {"token"=>"25162732", "nickname"=>"Dango Reinhardt", "last_four"=>"7483", "brand" => "MasterCard" , "user_id" => user.id}
			card_token = CardToken.build_card_token_with_hash hsh
			card_token.save
			card = Card.find(card_token.id)
			card_hsh = card.create_card_hsh({ "amount" => "105.00" , "unique_id" => "receiver_name_78"})
			card_hsh["cim_token"]   = "25162732"
			card_hsh["cim_profile"] = user.cim_profile
		end


	end

	it "should create a CardToken with hash" do
		user = FactoryGirl.create(:user, cim_profile: "7825348")
		hsh = {"token"=>"25162732", "nickname"=>"Dango Reinhardt", "last_four"=>"7483", "brand" => "visa"  , "user_id" =>  user.id}
		card_token = CardToken.build_card_token_with_hash hsh
		card_token.cim_token.should == "25162732"
		card_token.nickname.should  == "Dango Reinhardt"
		card_token.last_four.should == "7483"
		card_token.brand.should 	== "visa"
		card_token.user_id.should 	== user.id
	end

	it "should downcase the brand" do
		hsh = {"token"=>"25162732", "nickname"=>"Dango Reinhardt", "last_four"=>"7483", "brand" => "MasterCard" }
		card_token = CardToken.build_card_token_with_hash hsh
		card_token.save
		card_token.brand.should == "master"
		hsh = {"token"=>"25162732", "nickname"=>"Dango Reinhardt", "last_four"=>"7483", "brand" => "Visa" }
		card_token = CardToken.build_card_token_with_hash hsh
		card_token.save
		card_token.brand.should == "visa"
		hsh = {"token"=>"25162732", "nickname"=>"Dango Reinhardt", "last_four"=>"7483", "brand" => "Amex" }
		card_token = CardToken.build_card_token_with_hash hsh
		card_token.save
		card_token.brand.should == "american_express"
	end

    it "builds from factory with associations" do
        card = FactoryGirl.create :card_token
        card.should be_valid
        card.should_not be_a_new_record
    end


end# == Schema Information
#
# Table name: cards
#
#  id            :integer         not null, primary key
#  user_id       :integer
#  nickname      :string(255)
#  name          :string(255)
#  number_digest :string(255)
#  last_four     :string(255)
#  month         :string(255)
#  year          :string(255)
#  csv           :string(255)
#  brand         :string(255)
#  created_at    :datetime        not null
#  updated_at    :datetime        not null
#  cim_token     :string(255)
#

