=begin
  The Gama model encapsulates the fields of a Game. It controls when a game
  starts and when it ends. It communicates with the Socket Controller to
  notify when new users join the game and when it itself is done.
=end

class Gama < ActiveRecord::Base
  attr_accessible :name, :pending, :done, :limit
  validates :name, presence: true, length: { maximum: 50 }, uniqueness: true
  
  has_many :users

  # This returns true when the given limit of a game matches how many users
  # there are in the game.
  def full?
    self.users.count == self.limit
  end

  # Getter method for whether the game is pending (people can still join) or not
  def pending?
    self.pending
  end

  # Getter method for when the game is done
  def done?
    self.done
  end

  # We notify each user in this game that a new user has joined using the
  # WebSockets.
  def notify(new_user)
    self.users.each do |user|
      if user.id != new_user.id
        SocketController.user_joined(user, new_user)
      end
    end
  end

  # Once we are ready to start, the SocketController initializes the actual 
  # game entity that is passed between the back and front ends
  def start
    SocketController.init_game(self.users, self.id)
  end

  # We uncouple the users from this game and delete the game.
  def gameover
    self.users.each do |user|
      user.leave_game
    end
    self.done = true
    self.save

    Game.del(self.id)
  end
end
