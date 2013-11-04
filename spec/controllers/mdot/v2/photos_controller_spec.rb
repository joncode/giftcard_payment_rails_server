require 'spec_helper'

describe Mdot::V2::PhotosController do

    describe :update do
        it_should_behave_like("token authenticated", :put, :update, id: 1)

    end

end

