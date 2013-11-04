require 'spec_helper'

describe Mdot::V2::UsersController do

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

    describe :update do
        it_should_behave_like("token authenticated", :put, :update, id: 1)
        it_should_behave_like("correct token allowed", :put, :update, {id: 1}, "TokenGood")

    end

    describe :reset_passord do
        it_should_behave_like("token authenticated", :put, :reset_password)
        it_should_behave_like("correct token allowed", :put, :reset_password, nil, "TokenGood")

    end


end

