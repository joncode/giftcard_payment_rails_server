shared_examples_for "giver ducktype" do

    it "should have a name" do
        giver.name.class.should == String
    end

    it "should have a photo_url at :get_photo" do
        giver.get_photo.class.should == String
    end

    it "should have a photo_url at :get_photo" do
        giver.get_photo.class.should == String
    end

    it "should have a unique ID" do
        giver.id.class.should == Fixnum
    end

    it "should have a class" do
        ary = [Campaign, BizUser, AdminGiver, User]
        ary.include?(giver.class).should be_true
    end

end
