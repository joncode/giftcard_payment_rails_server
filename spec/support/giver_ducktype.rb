shared_examples_for "giver ducktype" do |object|

    it "should have a name" do
        object.name.should == String
    end

    it "should have a photo_url at :get_photo" do
        object.get_photo.should == String
    end
    
    it "should have a unique ID" do
        object.id.should == Fixnum
    end

    it "should have a class" do
        object.class.should == Campaign
    end

end
