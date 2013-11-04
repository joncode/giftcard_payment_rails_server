require 'spec_helper'

describe Mdot::V2::GiftsController do

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

    describe :regift do
        it_should_behave_like("token authenticated", :post, :regift, id: 1)
        it_should_behave_like("correct token allowed", :post, :regift, {id: 1}, "TokenGood")

    end

    describe :archive do
        it_should_behave_like("token authenticated", :get, :archive)
        it_should_behave_like("correct token allowed", :get, :archive, nil, "TokenGood")

    end

    describe :badge do
        it_should_behave_like("token authenticated", :get, :badge)
        it_should_behave_like("correct token allowed", :get, :badge, nil, "TokenGood")

    end

    describe :transactions do
        it_should_behave_like("token authenticated", :get, :transactions)
        it_should_behave_like("correct token allowed", :get, :transactions, nil, "TokenGood")

    end

    describe :open do
        it_should_behave_like("token authenticated", :post, :open, id: 1)
        it_should_behave_like("correct token allowed", :post, :open, {id: 1}, "TokenGood")

    end

    describe :redeem do
        it_should_behave_like("token authenticated", :post, :redeem, id: 1)
        it_should_behave_like("correct token allowed", :post, :redeem, {id: 1}, "TokenGood")

    end



end
