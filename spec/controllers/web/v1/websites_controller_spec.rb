require 'spec_helper'

describe WebsitesController do

    describe "#merchants" do

        describe "#show" do

            it "should return 401 unauthorized if www token not submitted in header" do
                get

            end

            it "should be a GET route" do

            end

            it "should respond with correct JSON merchant" do
                get :merchants, format: :json, token: receiver.remember_token
            end

        end

    end

end