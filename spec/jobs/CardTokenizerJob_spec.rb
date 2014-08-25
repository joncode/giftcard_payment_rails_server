require 'spec_helper'

describe CardTokenizerJob do

    describe :perform do

        before do
            User.delete_all
            @user = FactoryGirl.create :user
            @card = FactoryGirl.create :card
        end

        context "notify gift receiver on create" do
            it "should receive correct push message" do
                Card.any_instance.should_receive(:tokenize).and_return(true)
                CardTokenizerJob.perform @card.id
            end
        end
    end
end