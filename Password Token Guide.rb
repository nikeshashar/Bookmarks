#1) Test for request on password reset

feature "User forgets password" do 

	before(:each) do 
		User.create(:email => "nikeshashar@gmail.com",
					:password => 'test',
					:password_confirmation => 'test')
	end

	scenario "requests for password reset" do 
		visit '/users/forgot'
		expect(page).to have_content("Forgot password?")
	end

#2) 'Get' for direction to page forgot.erb

get '/users/forgot' do 
	@user = User.new
	erb :"users/forgot"
end

#3) Create page forgot.erb

Forgot password?
<form action="/users/forgot" method="post">
	Email: <input name="email" type="text" value="<%= @user.email %>">
	<input type="submit" value="Reset Password">
</form>

#4) User enters email address test
scenario "user enters right email address" do 
		visit '/users/forgot'
		fill_in 'email', with: "nikeshashar@gmail.com"
		click_on 'Reset Password'
		expect(page).to have_content("Password reset link sent to your email address")	
end

# 5) Post method for after entering email address (POST)

post '/users/forgot' do 
	email = params[:email]
	user = User.first(:email => params[:email] )
	if user
		token = create_new_token
		user.update(password_token: token,
					password_token_timestamp: create_new_timestamp)
		send_email(user, token)
		"Password reset link sent to your email address"
		redirect to '/'
end

# 6) User enters wrong email (test)

scenario "user enters email that is not registered" do 
		visit '/users/forgot'
		fill_in 'email', with: "wrongtest@test.com"
		click_on 'Reset Password'
		expect(page).to have_content("Sorry, wrongtest@test.com is not registered. Please sign up first!")
	end


# 7) Add this code to number 5

else
		flash[:errors] = ["Sorry, #{email} is not registered. Please sign up first!"]
		redirect to '/users/forgot'
	end 

# 8) Method for creating token & timestamp

def create_new_token
	(1..64).map{('A'..'Z').to_a.sample}.join
end

def create_new_timestamp
	Time.now 
end

# 9) Now tests for resetting password with token

feature "User resets password" do 
	before(:each) do 
	User.create(:email => "nikeshashar@gmail.com",
				:password => 'test',
				:password_confirmation => 'test',
				:password_token => "1token")	
	end

		scenario "User resets password with token" do 
		visit "users/reset_password/1token"
		digest = User.first.password_digest
		expect(page).to have_content("Hi, please enter your new password")
		fill_in 'new_password', with: "replace"
		fill_in 'new_password_confirmation', with: "replace"
		click_on 'Update'
		expect(User.first.password_digest).not_to eq digest
	end

# 10) 'get' for this test

get '/users/reset_password/:token' do 
	@token = params[:token]
	erb :"users/reset_password"
end

# 11) Form for resetting password in reset_password.erb

Hi, please enter your new password
<form action="/users/reset_password" method="post">
	Password:              <input name="new_password" type="password">
	Password Confirmation: <input name="new_password_confirmation" type="password">
	                       <input type="hidden", name="token", value="<%= @token %>">
	                       <input type="submit" value="Update">
</form>

# 12) Once the form is completed expect this action in Post

post '/users/reset_password' do
	token = params[:token]
	user = User.first(password_token: token)
	user.update(password: params[:new_password], password_confirmation: params[:new_password_confirmation])
	flash[:notice] = "Password changed"
	redirect to '/'
end

