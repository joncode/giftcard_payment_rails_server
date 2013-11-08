require 'spec_helper'

describe Mdot::V2::CardsController do

    before(:all) do
        unless user = User.find_by_remember_token("USER_TOKEN")
            user = FactoryGirl.create(:user)
            user.update_attribute(:remember_token, "USER_TOKEN")
        end
    end

    describe :index do
        it_should_behave_like("token authenticated", :get, :index)

    end

    describe :create do
        it_should_behave_like("token authenticated", :post, :create)

    end

    describe :destroy do
        it_should_behave_like("token authenticated", :delete, :destroy, id: 1)

    end


end
