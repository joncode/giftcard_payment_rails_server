require 'spec_helper'

describe SmsContact do

    it "builds from factory" do
        phone = FactoryGirl.build(:sms_contact)
        phone.should be_valid
    end

    it "should have a uniqueness validation on textword / phone" do
        phone  = FactoryGirl.create(:sms_contact)
        phone2 = SmsContact.create(textword: phone.textword, phone: phone.phone)
        phone2.id.should be_nil
        phone2.should_not be_valid
        phone2.should have_at_least(1).error_on(:textword)
    end

    it "should validate on :create but allow update" do
        phone  = FactoryGirl.create(:sms_contact, gift_id: nil)
        phone.update(gift_id: 12)
        phone.should be_valid
        phone.save
        phone.reload
        phone.gift_id.should == 12
    end

    it "should valide phone number to be a usable format" do
        phone = FactoryGirl.build(:sms_contact, phone: "invalid")
        phone.should_not be_valid
        phone.save
        phone.should have_at_least(1).error_on(:phone)
    end

    it "should find its gift via :gift" do
        gift = FactoryGirl.create(:gift)
        phone = FactoryGirl.create(:sms_contact, gift_id: gift.id)
        phone.gift.should == gift
    end

    it "should update gift_id with gift save thru association" do
        gift = FactoryGirl.build(:gift)
        phone = FactoryGirl.create(:sms_contact, gift_id: nil)
        gift.sms_contact = phone
        gift.save
        phone.reload
        phone.gift.should == gift
    end

    describe :bulk_create do

        it "should accept array of normalized sms contact hashes return array of SmsContacts" do
            contact_hsh = [{ "service_id" => 1001,"service" => "slicktext", "phone" => "2129886575", "subscribed_date" => "2013-02-04 21:10:45".to_datetime, "textword" => "itsonme" },{ "service_id" => 1002,"service" => "slicktext", "phone" => "2129884545", "subscribed_date" => "2013-02-04 21:11:45".to_datetime, "textword" => "itsonme" }]
            contacts = SmsContact.bulk_create(contact_hsh)
            contacts.class.should == Array
            contacts.count.should == 2
            contacts[0].service_id.should == 1001
            contacts[0].service.should    == "slicktext"
            contacts[1].textword.should   == "itsonme"
            contacts[1].phone.should      == "2129884545"
            contacts[1].subscribed_date.should == "2013-02-04 21:11:45".to_datetime
        end

        it "should accept array of normalized sms contact hashes and save them" do
            contact_hsh = [{ "service_id" => 1001,"service" => "slicktext", "phone" => "2129886575", "subscribed_date" => "2013-02-04 21:10:45".to_datetime, "textword" => "itsonme" },{ "service_id" => 1002,"service" => "slicktext", "phone" => "2129884545", "subscribed_date" => "2013-02-04 21:11:45".to_datetime, "textword" => "itsonme" }]
            SmsContact.bulk_create(contact_hsh)
            contacts = SmsContact.all
            contacts.count.should == 2

            contacts[0].service_id.should == 1001
            contacts[0].service.should    == "slicktext"
            contacts[1].textword.should   == "itsonme"
            contacts[1].phone.should      == "2129884545"
            contacts[1].subscribed_date.should == "2013-02-04 21:11:45".to_datetime
        end

        it "should not attempt to save unvalid records" do
            contact_hsh = [{ "service_id" => 1001,"service" => "slicktext", "phone" => "2129886575", "subscribed_date" => "2013-02-04 21:10:45".to_datetime, "textword" => "itsonme" },{ "service_id" => 1002,"service" => "slicktext", "phone" => "2129884545", "subscribed_date" => "2013-02-04 21:11:45".to_datetime, "textword" => "itsonme" }]
            SmsContact.bulk_create(contact_hsh)
            contacts = SmsContact.all
            contacts.count.should == 2
            contact_hsh = [{ "service_id" => 1001,"service" => "slicktext", "phone" => "2129886575", "subscribed_date" => "2013-02-04 21:10:45".to_datetime, "textword" => "itsonme" },{ "service_id" => 1002,"service" => "slicktext", "phone" => "2129884545", "subscribed_date" => "2013-02-04 21:11:45".to_datetime, "textword" => "itsonme" }]
            SmsContact.bulk_create(contact_hsh)
            contacts = SmsContact.all
            contacts.count.should == 2
        end
    end

end


# == Schema Information
#
# Table name: sms_contacts
#
#  id              :integer         not null, primary key
#  gift_id         :integer
#  subscribed_date :datetime
#  phone           :string(255)
#  service_id      :integer
#  service         :string(255)
#  textword        :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#

