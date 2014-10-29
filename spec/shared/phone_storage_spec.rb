shared_examples_for "phone storage" do
    it "should extract phone digits from dashed phone string" do
        object.phone =  "222-333-4567"
        object.save
        object.send(field).should_not == "222-333-4567"
        object.send(field).should == "2223334567"
    end

    it "should extract phone digits from dashed spaced and parenthesis phone string" do
        object.phone =  "(312) 404-1512"
        object.save
        object.send(field).should_not == "(312) 404-1512"
        object.send(field).should == "3124041512"
    end

end