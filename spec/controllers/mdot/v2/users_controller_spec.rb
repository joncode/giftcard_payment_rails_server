require 'spec_helper'

describe Mdot::V2::UsersController do

    describe :index do
        it_should_behave_like("token authenticated", :get, :index)

    end

    describe :create do
        it_should_behave_like("token authenticated", :post, :create)

    end

    describe :update do
        it_should_behave_like("token authenticated", :put, :update, id: 1)

    end

    describe :reset_passord do
        it_should_behave_like("token authenticated", :put, :reset_password)

    end


end

