require 'spec_helper'

describe BoomerangGiver do

    it_should_behave_like "giver ducktype" do
        let(:object) { FactoryGirl.create :boomerang_giver }
    end

    it "should associate with gift" do
        bgiver = FactoryGirl.create :boomerang_giver
        bgift = FactoryGirl.create :gift, giver_type: "BoomerangGiver", giver_id: BoomerangGiver.first.id
        bgift.giver_type.should == "BoomerangGiver"
        bgift.giver_id.should   == bgiver.id
        bgift.giver.class.name.should == "BoomerangGiver"
    end

    it "should respond to name with 'Boomerang'" do
        bgiver = FactoryGirl.create :boomerang_giver
        bgiver.name.should == "Boomerang"
    end

    it "should respond to photo methods" do
        bgiver = FactoryGirl.create :boomerang_giver
        bgiver.get_photo.should       == "http://res.cloudinary.com/drinkboard/image/upload/v1389818563/IOM-icon_round_bzokjj.png"
        bgiver.short_image_url.should == "d|v1389818563/IOM-icon_round_bzokjj.png"
    end
end
