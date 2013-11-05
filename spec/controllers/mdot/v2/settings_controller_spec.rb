require 'spec_helper'

describe Mdot::V2::SettingsController do

    before(:all) do
        unless user = User.find_by_remember_token("TokenGood")
            user = FactoryGirl.create(:user)
            user.update_attribute(:remember_token, "TokenGood")
        end
        puts "---> user = #{user.inspect}"
    end

    describe :index do
        it_should_behave_like("token authenticated", :get, :index)

    end

    describe :update do
        it_should_behave_like("token authenticated", :put, :update, id: 1)
        
    end


end
