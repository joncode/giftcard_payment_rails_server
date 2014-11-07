module UserSessionFactory

	def create_user_with_token token="FAKE_TOKEN", user=nil
		user = user || User.find_by(remember_token: token) || FactoryGirl.create(:user)
		st = user.session_tokens.first
		if st
			st.update(token: token)
		else
			st = user.session_tokens.create(token: token)
		end
		user.session_token_obj = st
        return user
	end

end