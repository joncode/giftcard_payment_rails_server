require 'spec_helper'

describe AppContact do

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

	it "has_many :users :through :users" do
		user = FactoryGirl.create(:user)
		user2 = FactoryGirl.create(:user)
		user3 = FactoryGirl.create(:user)
		ac = FactoryGirl.create(:app_contact)
		Friendship.create(user_id: user.id, app_contact_id: ac.id)
		Friendship.create(user_id: user2.id, app_contact_id: ac.id)
		Friendship.create(user_id: user3.id, app_contact_id: ac.id)
		ac.reload
		ac.users.count.should == 3
		ac.users[0].should == user
		ac.users[1].should == user2
		ac.users[2].should == user3
	end

	it "should reduce phone to digits only" do
		ac = AppContact.new(network: 'phone', network_id: '(718) 232- 7584')
		ac.save
		ac.network_id.should == "7182327584"
	end

	it "should downcase emails" do
		ac = AppContact.new(network: 'email', network_id: 'JONG@gmAIL.cOM')
		ac.save
		ac.network_id.should == "jong@gmail.com"
	end

	it "should enforce network + network_id uniqueness validation" do
		AppContact.create(network: "facebook", network_id: "782364192834")
		AppContact.create(network: "facebook", network_id: "782364192834")

		acs = AppContact.all
		acs.count.should == 1
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
