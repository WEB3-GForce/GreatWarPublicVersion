class User < ActiveRecord::Base
	# We save all emails as downcased versions to ensure uniqueness
	before_save { self.email = email.downcase }
	validates :name,  presence: true, length: { maximum: 50 }
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	# with the addition of the email indicies, the uniqueness option
	# also checks for these indices to be unique, thus fixing any
	# race conditions that might happen
	validates :email, presence: true, length: { maximum: 255 },
	                format: { with: VALID_EMAIL_REGEX },
	                uniqueness: { case_sensitive: false }

	# We use Rails secure hashing to hash an user's password
	# This includes:
	# 1) The ability to save a securely hashed password_digest attribute to 
	# 	the database
	# 2) A pair of virtual attributes18 (password and password_confirmation), 
	# 	including presence validations upon object creation and a validation 
	# 	requiring that they match
	# 3) An authenticate method that returns the user when the password is
	# 	correct (and false otherwise)

	# We need our model to have a password_digest attribute (hashed password)
	has_secure_password

	# Enforce password length
	validates :password, length: {minimum: 6}

	# Returns the hash digest of the given string.
	def User.digest(string)
		cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
	                                          BCrypt::Engine.cost
		BCrypt::Password.create(string, cost: cost)
	end

	# Now that we're using a string (token) to remember a User's session,
	# we generate the token through Rails urlsafe_base64 method:
	def User.new_token
		SecureRandom.urlsafe_base64
	end

	# We create a new token and store it's hash into the database so that 
	# a user persists
	def remember
		self.remember_token = User.new_token
		update_attributes(:remember_hash, User.digest(remember_token))
	end


	def authenticated?(remember_token)
		BCrypt::Password.new(remember_hash).is_password?(remember_token)
	end

end
