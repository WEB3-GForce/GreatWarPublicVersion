class Gama < ActiveRecord::Base
  attr_accessible :name, :pending, :done, :limit
  
  validates :name, presence: true, length: { maximum: 50 }, uniqueness: true
  
  has_many :users

  def full?
    self.users.count == self.limit
  end

  def pending?
    self.pending
  end

  def done?
    self.done
  end

  def notify(new_user)
    self.users.each do |user|
      if user.id != new_user.id
        SocketController.user_joined(user, new_user)
      end
    end
  end

  def start
    SocketController.init_game(self.users, self.id)
  end

  def surrender(loser)
    gama_id = loser.gama_id
    self.users.each do |user|
      user.leave_game
    end
    self.done = true
    self.save
    SocketController.gameover(gama_id)
  end
end
