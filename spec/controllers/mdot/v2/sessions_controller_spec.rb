require 'spec_helper'

describe Mdot::V2::SessionsController do

    describe :create do
        it_should_behave_like("token authenticated", :post, :create)

    end

    describe :login_social do
        it_should_behave_like("token authenticated", :post, :login_social)

    end


end
