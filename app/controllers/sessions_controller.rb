=begin
  The Sessions controller handles all the webpages that have to do with creating
  or deleting a session.
=end

class SessionsController < ApplicationController

	# GET /login
	def new
	end

	# POST /login
	def create
		# We use the sessions hash to find the user in this session. If there 
		# is a user and we can authenticate this user, then we log this user
		# in
		@user = User.find_by(email: params[:session][:email].downcase)
		if @user && @user.authenticate(params[:session][:password])
			log_in @user

			# This controls for the "Remember me" checkbox
			params[:session][:remember_me] == '1' ? remember(@user) : forget(@user)
				
			redirect_back_or @user
		else
			flash.now[:danger] = 'Invalid email/password combination'
			render 'new'
		end
	end

	def destroy
		log_out if logged_in?
		redirect_to root_url
	end
end