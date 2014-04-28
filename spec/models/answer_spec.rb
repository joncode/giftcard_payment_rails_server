require 'spec_helper'

describe Answer do

    it "should accept hash and create answer - BUG FIX" do
        user = FactoryGirl.create(:user)
        request_hsh = {"data"=>[{"answer"=>"0", "left"=>"Day Drinking", "right"=>"Night Drinking", "question_id"=>"1"}, {"answer"=>"1", "left"=>"Red Wine", "right"=>"White Wine", "question_id"=>"2"}, {"answer"=>"0", "left"=>"White Liqours", "right"=>"Brown Liqours", "question_id"=>"3"}, {"answer"=>"0", "left"=>"Straw", "right"=>"No straw", "question_id"=>"4"}]}
        Answer.save_these(request_hsh["data"], user)
        answers = Answer.all
        request_hsh["data"].each do |req|
            db_answer = answers.where(question_id: req["question_id"].to_i).first
            db_answer.answer.should == req["answer"]
        end
    end


end