=begin
  The Sessions Helper has all the helper functions to make sure that a session
  is being stored correctly. This also handles whether a User is remembered
  after they close the browser or not.
=end

module SessionsHelper
  def log_in(user)
    user.channel = User.new_token
    user.logged = true
    user.save
    session[:user_id] = user.id
  end

  # Returns the current logged-in user (if any).
  def current_user
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.signed[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  # This is to supplement the All page for Users
  def logged_in?
    !current_user.nil?
  end

  def logged? (user)
    user.logged
  end


  def log_out
    forget(current_user)
    @current_user.update_attribute :logged, false
    session.delete(:user_id)
    @current_user = nil
  end

  # This populates cookie hash with a safe string so that the user
  # will be remembered across sessions
  def remember(user)
	user.remember
	cookies.permanent.signed[:user_id] = user.id
	cookies.permanent[:remember_token] = user.remember_token
  end

  # This assures that no cookies are stored
  def forget(user)
	user.forget
	cookies.delete(:user_id)
	cookies.delete(:remember_token)
  end


  # Returns true if the given user is the current user.
  def current_user?(user)
    user == current_user
  end


  # Redirects to stored location (or to the default).
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  # Stores the URL trying to be accessed.
  def store_location
    session[:forwarding_url] = request.url if request.get?
  end
end
