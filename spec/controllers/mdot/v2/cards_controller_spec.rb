require 'spec_helper'

describe Mdot::V2::CardsController do

    before(:all) do
        unless user = User.find_by_remember_token("TokenGood")
            user = FactoryGirl.create(:user)
            user.update_attribute(:remember_token, "TokenGood")
        end
        puts "---> user = #{user.inspect}"
    end

    describe :index do
        it_should_behave_like("token authenticated", :get, :index)
        it_should_behave_like("correct token allowed", :get, :index, nil, "TokenGood")

    end

    describe :create do
        it_should_behave_like("token authenticated", :post, :create)
        it_should_behave_like("correct token allowed", :post, :create, nil, "TokenGood")

    end

    describe :destroy do
        it_should_behave_like("token authenticated", :delete, :destroy, id: 1)
        it_should_behave_like("correct token allowed", :delete, :destroy, {id: 1}, "TokenGood")

    end


end
