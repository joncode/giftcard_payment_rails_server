require 'spec_helper'

include AffiliateFactory

describe "Affiliate User Feature" do

	it "should associate user with affiliate via link" do
		a1 = make_affiliate("Afff", "One")
		a1.total_users.should == 0
		lp = FactoryGirl.create(:landing_page, link: "itson.me/san-diego?aid=twister_ice_tea", clicks: 2, affiliate_id: a1.id)
		new_aff_user = {"first_name" => "First", "email" => "aff@user.com", "password" => "passpass", "password_confirmation"=> "passpass", "last_name" => "archangle", "link" => "itson.me/san-diego?aid=twister_ice_tea" }
		u = User.new(new_aff_user)
		u.save.should be_true
		a1.reload
		a1.total_users.should == 1
		a1.users.count.should == 1
		a1.users.first.should == u
		lp.reload.users.should == 1
		u.affiliation.name.should == "FA"
	end

end