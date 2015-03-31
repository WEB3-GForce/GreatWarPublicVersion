module SessionsHelper
	def log_in(user)
		user.update_attribute :logged, true
		session[:user_id] = user.id
	end

	# Returns the current logged-in user (if any).
	def current_user
		@current_user ||= User.find_by(id: session[:user_id])
	end

	def logged_in?
		!current_user.nil?
	end

	def log_out (user)
		user.update_attribute :logged, false
		session.delete(:user_id)
		@current_user = nil
	end

	def remember(user)
		user.remember
		cookies.permanent.signed[:user_id] = user.id
		cookies.permanent[:remember_token] = remember_token
	end
end
