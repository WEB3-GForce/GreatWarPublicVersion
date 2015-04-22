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
end
