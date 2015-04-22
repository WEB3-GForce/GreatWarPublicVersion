class Gama < ActiveRecord::Base
  attr_accessible :name, :pending, :done, :limit
  
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

  def surrender(user)
    self.done = true
    self.save
    # notify other user
  end
end
