module UserSessionFactory

	def create_user_with_token token, user=nil
		if user
			st = user.session_tokens.first
	        st.update(token: token)
	    else
	        unless user = User.find_by(remember_token: token)
	            user = FactoryGirl.create(:user)
	            st = user.session_tokens.first
	            st.update(token: token)
	            # @user.update_attribute(:remember_token, "USER_TOKEN")
	        end
	    end
        return user
	end

end