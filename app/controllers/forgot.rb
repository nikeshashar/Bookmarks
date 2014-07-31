get '/users/forgot' do 
	@user = User.new
	erb :"users/forgot"
end

post 'user/forgot' do
	if user
			user.password_token = (1..64).map{('A'..'Z').to_a.sample}.join
			user.password_token_timestamp = Time.now
			user.save!
			notify user.email, user.password_token
			flash[:notice] = "Password reset email sent to #{email}"
			redirect to '/'
		else
			flash[:errors] = ["Sorry, #{email} is not registered. Please sign up first!"]
			redirect to '/users/forgot'
		end
end
