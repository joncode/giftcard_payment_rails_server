require 'spec_helper'

describe AppContact do

    describe :upload do

        before(:each)do
            @current_user = FactoryGirl.create(:user)
            @ary = [{ "672342" => { "first_name" => "tommy" ,"last_name" => "hilfigure", "email" => [ "email1@gmail.com", "email2@yahoo.com"], "phone" => [ "3102974545", "6467586473"], "twitter" => [ "2i134o1234123"], "facebook" => [ "23g2381d103dy1"] }}, { "22" => { "first_name" => "Jenifer" ,"last_name" => "Bowie", "email" => [ "jenny@facebook.com"], "phone" => ["7824657878"]}}]
        end

        it "should accept ary of contacts separated by ID and make array of app_contacts" do
            ac = AppContact.upload(contacts: @ary, user: @current_user)
            ac.count.should == 8
            ac.first.network.should    == "email"
            ac.first.network_id.should == "email1@gmail.com"
            ac.first.name.should       == "tommy hilfigure"
        end

        it "should save all the app_contacts in the database" do
            AppContact.upload(contacts: @ary, user: @current_user)
            contacts = AppContact.all
            contacts.count.should == 8
            contact = contacts.first
            contact.network.should == "email"
            contact.network_id.should == "email1@gmail.com"
            contact.name.should       == "tommy hilfigure"
        end
    end

    it "builds from factory" do
        app_contact = FactoryGirl.build :app_contact
        app_contact.should be_valid
    end

    it "require network" do
        app_contact = FactoryGirl.build(:app_contact, :network => nil)
        app_contact.should_not be_valid
        app_contact.should have_at_least(1).error_on(:network)
    end

    it "requires network_id" do
        app_contact = FactoryGirl.build(:app_contact, :network_id => nil)
        app_contact.should_not be_valid
        app_contact.should have_at_least(1).error_on(:network_id)
    end

    it "require user_id" do
        app_contact = FactoryGirl.build(:app_contact, :user_id => nil)
        app_contact.should_not be_valid
        app_contact.should have_at_least(1).error_on(:user_id)
    end

    it "belongs to user" do
        user = FactoryGirl.create(:user)
        ac = FactoryGirl.create(:app_contact, user: user)
        ac.reload
        ac.user.should == user
    end

    it "should valide phone number to be a usable format" do
        ac = FactoryGirl.build(:app_contact, network: "phone", network_id: "invalid")
        ac.should_not be_valid
        ac.save
        ac.should have_at_least(1).error_on(:phone)
    end

end

  # create_table "app_contacts", force: true do |t|
  #   t.integer  "user_id"
  #   t.string   "network"
  #   t.string   "network_id"
  #   t.string   "name"
  #   t.date     "birthday"
  #   t.string   "handle"
  #   t.datetime "created_at"
  #   t.datetime "updated_at"
  # end
