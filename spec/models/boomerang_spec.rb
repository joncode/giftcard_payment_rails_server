require 'spec_helper'

describe Boomerang do

    it_should_behave_like "giver ducktype" do
        let(:object) { FactoryGirl.create :boomerang }
    end

    it "should associate with gift" do
        bgiver = FactoryGirl.create :boomerang
        bgift  = FactoryGirl.create :gift, giver_id:  bgiver.id, giver_type: "Boomerang", giver_name: bgiver.name
        bgift.giver_type.should  == "Boomerang"
        bgift.giver_id.should    == bgiver.id
        bgift.giver.class.should == Boomerang
        bgift.giver_name.should  == "Boomerang"
    end

    it "should respond to name with 'Boomerang'" do
        bgiver = FactoryGirl.create :boomerang
        bgiver.name.should == "Boomerang"
    end

    it "should respond to photo methods" do
        bgiver = FactoryGirl.create :boomerang
        bgiver.get_photo.should       == "http://res.cloudinary.com/drinkboard/image/upload/v1402519573/boomerang_120x120_clshuw.png"
        bgiver.short_image_url.should == "d|v1402519573/boomerang_120x120_clshuw.png"
    end
end
# == Schema Information
#
# Table name: boomerangs
#
#  id :integer         not null, primary key
#

