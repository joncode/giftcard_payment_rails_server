shared_examples_for "payable ducktype" do

    it "send a non-saved object into payable ducktype" do
        object.id.should be_nil
        object.should be_valid
    end

    it "should respond to :success?" do
#        object.success?.should be_false
        object.save
#        object.success?.should be_true
        object.success?.class.should == (TrueClass || FalseClass)
    end

    it "should respond to :resp_code" do
#        object.resp_code.should == 3
        object.save
#        object.resp_code.should == 1
        object.resp_code.class.should == Fixnum
    end

    it "should respond to :reason_text" do
        # [[], nil].should include(object.reason_text)
        object.save
        # object.reason_text.should == "This transaction has been approved."
        object.reason_text.class.should == String
    end

    it "should respond to :reason_code" do
#        object.reason_code.should == 2
        object.save
#        object.reason_code.should == 1
        object.reason_code.class.should == Fixnum
    end

end