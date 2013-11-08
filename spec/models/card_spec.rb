require 'spec_helper'
require 'json_helper'

describe Card do

    it "builds from factory with associations" do
        card = FactoryGirl.create :card
        card.should be_valid
        card.should_not be_a_new_record
    end

    context "validation" do

        it "requires csv" do
          card = FactoryGirl.build(:card, :csv => nil)
          card.should_not be_valid
          card.should have_at_least(1).error_on(:csv)
        end

        it "requires month" do
          card = FactoryGirl.build(:card, :month => nil)
          card.should_not be_valid
          card.should have_at_least(1).error_on(:month)
        end

        it "requires year" do
          card = FactoryGirl.build(:card, :year => nil)
          card.should_not be_valid
          card.should have_at_least(1).error_on(:year)
        end

        it "requires name" do
          card = FactoryGirl.build(:card, :name => nil)
          card.should_not be_valid
          card.should have_at_least(1).error_on(:name)
        end

        it "requires nickname" do
          card = FactoryGirl.build(:card, :nickname => nil)
          card.should_not be_valid
          card.should have_at_least(1).error_on(:nickname)
        end

        it "requires user_id" do
          card = FactoryGirl.build(:card, :user_id => nil)
          card.should_not be_valid
          card.should have_at_least(1).error_on(:user_id)
        end

        it "should validate that name has atleast 2 words in it" do
            cc_hsh = {"month"=> "12", "number"=>"4222222222222222", "user_id"=>772, "name"=>"Tsuboi", "year"=>"2018", "csv"=>"910", "nickname"=>"Dango"}
            card = Card.create_card_from_hash cc_hsh
            card.save
            card.should have_at_least(1).error_on(:name)
        end

        it "should check the validity of the year, month, number" do
            cc_hsh = {"month"=> "NOWAY", "number"=>"NOWAY", "user_id"=>772, "name"=>"Hiromi Tsuboi", "year"=>"NOWAY", "csv"=>"910", "nickname"=>"Dango"}
            card = Card.create_card_from_hash cc_hsh
            card.save
            card.should have_at_least(1).error_on(:month)
            card.should have_at_least(1).error_on(:year)
            card.should have_at_least(1).error_on(:number)
            card.should have_at_least(2).error_on(:brand)
        end

        it "should require that the month and year are in the future" do
            past_date   = Time.now - 3.months
            cc_hsh = {"month"=>past_date.month.to_s, "number"=>"4417121029961508", "user_id"=>772, "name"=>"Hiromi Tsuboi", "year"=>past_date.year.to_s, "csv"=>"910", "nickname"=>"Dango"}
            card = Card.create_card_from_hash cc_hsh
            card.save
            card.should have_at_least(1).error_on(:expiration)
            card.errors[:expiration].should == ["The expiration date must be in the future."]
        end

        it "should require a 1-12 month" do
            cc_hsh = {"month"=> "15", "number"=>"4417121029961508", "user_id"=>772, "name"=>"Hiromi Tsuboi", "year"=>"2017", "csv"=>"910", "nickname"=>"Dango"}
            card = Card.create_card_from_hash cc_hsh
            card.save
            card.should have_at_least(1).error_on(:expiration)
            card.errors[:expiration].should == ["Date is not valid"]
        end


    end

    context "associations" do

        let(:card) { FactoryGirl.create :card }

        it "should belong to a user" do
            card.respond_to?(:user).should be_true
        end

        it "should have many sales" do
            card.respond_to?(:sales).should be_true
        end

        it "should have many orders" do
            card.respond_to?(:orders).should be_true
        end

        it "should have many gifts" do
            card.respond_to?(:gifts).should be_true
        end
    end

    context "getters" do

        it "should return month and year combined" do
            card = FactoryGirl.create :card
            card.month_year.should == "0217"
        end

        it "should get user first name and last name" do
            card = FactoryGirl.create :card
            card.first_name.should == "Plain"
            card.last_name.should  == "Joseph"
        end

        it "should decrypt card data for charge" do
            card  = FactoryGirl.create(:card)
            card.decrypt! CATCH_PHRASE
            card.number.should == "4417121029961508"
        end

        it "should get public display user cards" do
            User.delete_all
            user = FactoryGirl.create(:user, :email => "newbieddsf@sdskfjs.com")
            10.times do
                FactoryGirl.create(:card, user_id: user.id)
            end
            cards = Card.get_cards user
            cards.class.should == Array
            hsh = cards[0]
            hsh.class.should == Hash
            keys = ["card_id", "last_four", "nickname"]
            compare_keys hsh, keys
        end

    end

    context "create" do

        it "should receive cc hash and create card" do
            cc_hsh = {"month"=>"02", "number"=>"4417121029961508", "user_id"=>772, "name"=>"Hiromi Tsuboi", "year"=>"2016", "csv"=>"910", "nickname"=>"Dango"}
            card = Card.create_card_from_hash cc_hsh
            card.save
            card.errors.count.should == 0
            puts card.errors
            card.class.should == Card
            keys = ["month", "user_id", "brand", "name", "year", "csv", "nickname"]
            card.month.should    == cc_hsh["month"]
            card.user_id.should  == cc_hsh["user_id"]
            card.brand.should    == 'visa'
            card.name.should     == cc_hsh["name"]
            card.year.should     == cc_hsh["year"]
            card.csv.should      == cc_hsh["csv"]
            card.nickname.should == cc_hsh["nickname"]
        end

        it "should create last_four when saving" do
            cc_hsh = {"month"=>"02", "number"=>"4417121029961508", "user_id"=>772,  "name"=>"Hiromi Tsuboi", "year"=>"2016", "csv"=>"910", "nickname"=>"Dango"}
            card = Card.create_card_from_hash cc_hsh
            card.save
            card.last_four.should ==  "1508"
        end

        it "should save number encrypted and not save number" do
            card = FactoryGirl.create(:card)
            card_id = card.id
            new_card = Card.find card_id
            new_card.number.should be_nil
            new_card.number_digest.class.should  == String
            new_card.number_digest.length.should > 23
        end

    end



    # it "requires number" do
    #   card = FactoryGirl.build(:card,  number => nil)
    #   card.should_not be_valid
    #   card.should have_at_least(1).error_on( number)
    # end

    # it "requires passphrase" do
    #   card = FactoryGirl.build(:card, :passphrase => nil)
    #   card.should_not be_valid
    #   card.should have_at_least(1).error_on(:passphrase)
    # end



end