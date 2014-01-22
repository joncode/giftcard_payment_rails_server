require 'spec_helper'

describe Mdot::V2::UserSocialsController do

    describe :destroy do

        it_should_behave_like("token authenticated", :delete, :destroy, id: 1)

        it "should return user_social ID on success" do

        end

        it "should deActivate the user social in the database" do

        end

        it "should return 404 with no ID or wrong ID" do
            
        end

    end

end