require 'spec_helper'

describe User do

  it "should downcase email" do
    user = FactoryGirl.create :user, { email: "KJOOIcode@yahoo.com" }
    user.email.should == "kjooicode@yahoo.com"
    puts user.inspect
  end

end