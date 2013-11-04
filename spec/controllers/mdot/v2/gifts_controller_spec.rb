require 'spec_helper'

describe Mdot::V2::GiftsController do

    describe :index do
        it_should_behave_like("token authenticated", :get, :index)

    end

    describe :create do
        it_should_behave_like("token authenticated", :post, :create)

    end

    describe :regift do
        it_should_behave_like("token authenticated", :post, :regift, id: 1)

    end

    describe :archive do
        it_should_behave_like("token authenticated", :get, :archive)

    end

    describe :badge do
        it_should_behave_like("token authenticated", :get, :badge)

    end

    describe :transactions do
        it_should_behave_like("token authenticated", :get, :transactions)

    end

    describe :open do
        it_should_behave_like("token authenticated", :post, :open, id: 1)

    end

    describe :redeem do
        it_should_behave_like("token authenticated", :post, :redeem, id: 1)

    end



end
