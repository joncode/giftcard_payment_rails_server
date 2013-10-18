require 'spec_helper'

describe Mt::V2::MenusController do

    before(:each) do
        request.env["HTTP_TKN"] = "nj3tOdJOaZa-qFx0FhCLRQ"

        Provider.delete_all
        @provider = FactoryGirl.create(:provider)
    end

    describe "#update" do
        pending "nested tests needed"
    end

end