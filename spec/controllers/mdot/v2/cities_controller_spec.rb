require 'spec_helper'

describe Mdot::V2::CitiesController do

    describe :index do
        it_should_behave_like("token authenticated", :get, :index)

    end

end
