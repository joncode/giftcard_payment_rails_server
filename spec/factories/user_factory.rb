module UserFactory


	def make_user(first,last)
		FactoryGirl.create(:user, first_name: first.capitalize, last_name: last.capitalize, email: "#{first}@#{last}.com".downcase)
	end














end