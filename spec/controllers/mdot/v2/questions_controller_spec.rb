require 'spec_helper'

describe Mdot::V2::QuestionsController do

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

    describe :update do
        it_should_behave_like("token authenticated", :put, :update, id: 1)
        it_should_behave_like("correct token allowed", :put, :update, {id: 1}, "TokenGood")

    end


end
