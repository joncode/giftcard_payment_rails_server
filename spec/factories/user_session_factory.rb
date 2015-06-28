module UserSessionFactory

	def create_user_with_token token="FAKE_TOKEN", user=nil, client=nil
		user = user || User.find_by(remember_token: token) || FactoryGirl.create(:user)
		st = user.session_tokens.first
		if st
			st.update(token: token)
		else
			st = user.session_tokens.create(token: token)
		end

		if client
			st.partner_id = client.partner_id
			st.partner_type = client.partner_type
			st.client_id = client.id
			st.save
		end
		user.session_token_obj = st
        return user
	end

end



	def make_affiliate(first, last)
		FactoryGirl.create(:affiliate,
			first_name: first.capitalize,
			last_name: last.capitalize,
			email: "#{first}@#{last}.com".downcase,
			url_name: "#{first}_#{last}".downcase)
	end

	def make_partner_client(first, last)
		a = make_affiliate(first,last)
		FactoryGirl.create(:client, partner_id: a.id, partner_type: a.class.to_s)
	end