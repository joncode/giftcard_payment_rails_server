shared_examples_for "giver ducktype" do

    it "should have a name" do
        object.name.class.should == String
    end

    it "should have a photo_url at :get_photo" do
        object.get_photo.class.should == String
    end

    it "should have a unique ID" do
        object.id.class.should == Fixnum
    end

    it "should have a class" do
        ary = [Campaign, BizUser, AdminGiver, User]
        ary.include?(object.class).should be_true
    end

    it "should have :shorten_image_url" do
        object.respond_to?(:short_image_url).should be_true
    end

end
