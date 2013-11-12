require 'spec_helper'

describe Mdot::V2::QuestionsController do

    before(:each) do
        User.delete_all
        Question.delete_all
        Answer.delete_all
        unless @user = User.find_by(remember_token: "USER_TOKEN")
            @user = FactoryGirl.create(:user)
            @user.update_attribute(:remember_token, "USER_TOKEN")
        end
        qs = [["Day Drinking", "Night Drinking"], ["Red Wine", "White Wine"], ["White Liqours", "Brown Liqours"], ["Straw", "No straw"], ["Light Beer", "Dark Beer"], ["Mimosa", "Bloody Mary"], ["Rare", "Well Done"], ["City Vacation", "Beach Vacation"], ["Shaken", "Stirred"], ["Rocks", "Neat"], ["Sweet", "Sour"], ["Steak", "Fish"]]
        qs.each do |q|
            Question.create(left: q[0], right: q[1])
        end
    end

    describe :index do
        it_should_behave_like("token authenticated", :get, :index)

        it "should get the app users questions" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            get :index, format: :json
            response.response_code.should == 200
            json["status"].should == 1
            json["data"].class.should == Array
            question = json["data"].first
            keys = ["left", "right", "question_id"]
            # ANSWER KEY IS LEFT OFF CAUSE ITS OPTIONAL
            compare_keys(question, keys)
        end
    end

    describe :update do
        it_should_behave_like("token authenticated", :put, :update, id: 1)

        let(:q1) {Question.find_by(left: "Day Drinking")}
        let(:q2) {Question.find_by(left: "Red Wine")}
        let(:q3) {Question.find_by(left: "White Liqours")}
        let(:q4) {Question.find_by(left: "Straw")}
        let(:q5) {Question.find_by(left: "Light Beer")}
        let(:q6) {Question.find_by(left: "Mimosa")}
        let(:q7) {Question.find_by(left: "Rare")}

        it "should update requests with json'd answers" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            params = "[  {    \"question_id\" : #{q1.id},    \"left\" : \"Day Drinking\",    \"answer\" : \"0\",    \"right\" : \"Night Drinking\"  },  {    \"question_id\" : #{q2.id},    \"left\" : \"Red Wine\",    \"answer\" : \"0\",    \"right\" : \"White Wine\"  },  {    \"question_id\" : #{q3.id},    \"left\" : \"White Liqours\",    \"answer\" : \"0\",    \"right\" : \"Brown Liqours\"  },  {    \"question_id\" : #{q4.id},    \"left\" : \"Straw\",    \"answer\" : \"0\",    \"right\" : \"No straw\"  },  {    \"question_id\" : #{q5.id},    \"left\" : \"Light Beer\",    \"answer\" : \"0\",    \"right\" : \"Dark Beer\"  },  {    \"question_id\" : #{q6.id},    \"left\" : \"Mimosa\",    \"answer\" : \"0\",    \"right\" : \"Bloody Mary\"  },  {    \"question_id\" : #{q7.id},    \"left\" : \"Rare\",    \"answer\" : \"0\",    \"right\" : \"Well Done\"  }]"
            #params = [{ "question_id" => q1.id, "answer" => 0},{ "question_id" => q2.id, "answer" => 0},{ "question_id" => q3.id, "answer" => 0},{ "question_id" => q4.id, "answer" => 0},{ "question_id" => q5.id, "answer" => 0},{ "question_id" => q6.id, "answer" => 0},{ "question_id" => q7.id, "answer" => 0}].to_json
            put :update, format: :json, data: params
            response.response_code.should == 200
            json["status"].should == 1
            json["data"].class.should == Array
            question          = json["data"].first
            keys              = ["left", "right", "question_id", "answer"]
            compare_keys(question, keys)
            answers = @user.answers
            [q1,q2,q3,q4,q5,q6,q7].each do |q|
                a = answers.where(question_id: q.id).first
                a.answer.should == "0"
            end
        end

        it "should update requests with hash answers" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            params = [{ "question_id" => q1.id, "answer" => 0},{ "question_id" => q2.id, "answer" => 0},{ "question_id" => q3.id, "answer" => 0},{ "question_id" => q4.id, "answer" => 0},{ "question_id" => q5.id, "answer" => 0},{ "question_id" => q6.id, "answer" => 0},{ "question_id" => q7.id, "answer" => 0}].to_json

            put :update, format: :json, data: params
            response.response_code.should == 200
            json["status"].should == 1
            json["data"].class.should == Array
            question          = json["data"].first
            keys              = ["left", "right", "question_id", "answer"]
            compare_keys(question, keys)
            answers = @user.answers
            [q1,q2,q3,q4,q5,q6,q7].each do |q|
                a = answers.where(question_id: q.id).first
                a.answer.should == "0"
            end
        end

        it "should ignore bad keys" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            params = [{ "question_id" => q1.id, "answer" => 0},{ "question_id" => q2.id, "answer" => 0},{ "question_id" => q3.id, "answer" => 0},{ "question_id" => q4.id, "answer" => 0},{ "question_id" => q5.id, "answer" => 0},{ "question_id" => q6.id, "answer" => 0},{ "question_id" => q7.id, "answer" => 0}].to_json

            put :update, format: :json, data: params
            response.response_code.should == 200
            json["status"].should == 1
            json["data"].class.should == Array
            question          = json["data"].first
            keys              = ["left", "right", "question_id", "answer"]
            compare_keys(question, keys)
        end

        it "should reject bad requests" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            put :update, format: :json, data: "total garbage"
            response.response_code.should == 400
            put :update, format: :json, data: {"doest" => "bs", "take" => "bs", "arrays" => "bs"}
            response.response_code.should == 400
        end
    end
end
