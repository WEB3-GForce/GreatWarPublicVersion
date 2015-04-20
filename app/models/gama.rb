class Gama < ActiveRecord::Base
	attr_accessible :name, :pending, :done, :limit, :players

	#validates :name,  presence: true, length: { maximum: 50 }
end
