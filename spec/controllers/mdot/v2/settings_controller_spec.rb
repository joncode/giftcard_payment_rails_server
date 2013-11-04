require 'spec_helper'

describe Mdot::V2::SettingsController do

    describe :index do
        it_should_behave_like("token authenticated", :get, :index)

    end

    describe :update do
        it_should_behave_like("token authenticated", :put, :update, id: 1)

    end


end
