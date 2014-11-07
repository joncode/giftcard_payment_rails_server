shared_examples_for "email storage" do

	it "should downcase emails" do
		object.email  = 'JONG@gmAIL.cOM'
		object.save
		object.email.should == "jong@gmail.com"
	end

	it "should reject incorrectly formatted emails" do
		object.email  = 'J@NG@gmAIL.cOM'
		object.save
		object.should have_at_least(1).error_on(field)
	end

end