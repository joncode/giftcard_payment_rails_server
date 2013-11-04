require 'spec_helper'

describe Mdot::V2::SessionsController do

    before(:all) do
        unless user = User.find_by_remember_token("TokenGood")
            user = FactoryGirl.create(:user)
            user.update_attribute(:remember_token, "TokenGood")
        end
        puts "---> user = #{user.inspect}"
    end

    describe :create do
        it_should_behave_like("token authenticated", :post, :create)
        it_should_behave_like("correct token allowed", :post, :create, nil, "TokenGood")

    end

    describe :login_social do
        it_should_behave_like("token authenticated", :post, :login_social)
        it_should_behave_like("correct token allowed", :post, :login_social, nil, "TokenGood")

    end


end
