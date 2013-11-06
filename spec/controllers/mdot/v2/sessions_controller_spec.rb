require 'spec_helper'

describe Mdot::V2::SessionsController do

    before(:all) do
        unless user = User.find_by_remember_token("TokenGood")
            user = FactoryGirl.create(:user)
            user.update_attribute(:remember_token, "TokenGood")
        end
    end

    describe :create do
        it_should_behave_like("token authenticated", :post, :create)

    end

    describe :login_social do
        it_should_behave_like("token authenticated", :post, :login_social)

    end


end
