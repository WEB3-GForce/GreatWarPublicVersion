=begin
  The User model encapsulates the fields of a User. It controls when a game
  starts and when it ends. It communicates with the Socket Controller to
  notify when new users join the game and when it itself is done.
=end

class User < ActiveRecord::Base
  attr_accessor :remember_token
  attr_accessible :name, :email, :logged, :password, :password_confirmation, :game, :host
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

  belongs_to :gama

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
  validates :password, length: {minimum: 6}, allow_blank: true

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
  # a user persists even if they close the browser
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_hash, User.digest(remember_token))
  end

  # Checks to see if the rememer_hash stored for this User is the same as the
  # one stored in the cookies
  def authenticated?(remember_token)
    return false if remember_hash.nil?
    BCrypt::Password.new(remember_hash).is_password?(remember_token)
  end


  # This prohibits from the remember_hash to be initialized if the user does not
  # choose to remember their session
  def forget
    update_attribute(:remember_hash, nil)
  end

  def leave_game
    self.gama_id = nil
    self.host = false
    self.save
  end

  # Boolean method to see if this User is the host of the given game.
  def is_host?(gama)
    return self.host && (self.gama_id == gama.id)
  end

  def gravatar
    gravatar_id = Digest::MD5::hexdigest(self.email.downcase)
    "https://secure.gravatar.com/avatar/#{gravatar_id}"
  end
end
