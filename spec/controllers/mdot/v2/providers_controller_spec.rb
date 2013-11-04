require 'spec_helper'

describe Mdot::V2::ProvidersController do

    describe :index do
        it_should_behave_like("token authenticated", :get, :index)

    end

    describe :show do
        it_should_behave_like("token authenticated", :get, :show, id: 1)

    end

    describe :menu do
        it_should_behave_like("token authenticated", :get, :menu, id: 1)

    end

end
