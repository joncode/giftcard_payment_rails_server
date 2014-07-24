shared_examples_for "gift status" do

    it "should set status" do
        good = ["incomplete" , "open"]
        good.should include(object.status)
    end

    it "should set pay_stat" do
        object.pay_stat.should == "charge_unpaid"
    end

    it "should set cat" do
        object.cat.should == cat
    end

    it "should persist" do
        object.persisted?.should be_true
    end


end