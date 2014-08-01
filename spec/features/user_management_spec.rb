require 'spec_helper'
require_relative 'helpers/session'

include SessionHelpers

feature "User signs in" do 

	before(:each) do 
		User.create(:email => "test@test.com",
					:password => 'test',
					:password_confirmation => 'test')
	end

	scenario "with correct credentials" do 
		visit '/'
		expect(page).not_to have_content("Welcome, test@test.com")
		sign_in('test@test.com', 'test')
		expect(page).to have_content("Welcome, test@test.com")
	end

	scenario "with incorrect credentials" do 
		visit '/'
		expect(page).not_to have_content("Welcome, test@test.com")
		sign_in('test@test.com', 'wrong')
		expect(page).not_to have_content("Welcome, test@test.com")
	end
end

feature 'User signs out' do 
	before(:each) do 
		User.create(:email => "test@test.com",
					:password => 'test',
					:password_confirmation => 'test')
	end

	scenario 'while being signed in' do 
		sign_in('test@test.com', 'test')
		click_button "Sign out"
		expect(page).to have_content("Good bye!")
		expect(page).not_to have_content("Welcome, test@test.com")
	end
end

feature "User signs up" do 
	scenario "when being logged out" do 
		expect { sign_up }.to change(User, :count).by(1)
		expect(page).to have_content("Welcome, alice@example.com")
		expect(User.first.email).to eq("alice@example.com")
	end

	scenario "with a password that doesn't match" do 
		expect { sign_up('a@a.com', 'pass', 'wrong') }.to change(User, :count).by(0)
		expect(current_path).to eq('/users')
		expect(page).to have_content("Sorry, your passwords don't match")
	end

	scenario "with an email that is already registered" do
		expect { sign_up }.to change(User, :count).by(1)
		expect { sign_up }.to change(User, :count).by(0)
		expect(page).to have_content("This email is already taken")
	end
end

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

	scenario "user enters email that is not registered" do 
		visit '/users/forgot'
		fill_in 'email', with: "wrongtest@test.com"
		click_on 'Reset Password'
		expect(page).to have_content("Sorry, wrongtest@test.com is not registered. Please sign up first!")
	end

	scenario "user enters right email address" do 
		visit '/users/forgot'
		fill_in 'email', with: "nikeshashar@gmail.com"
		click_on 'Reset Password'
		expect(page).to have_content("Password reset link sent to your email address")	
	end
end

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


end


