class Gama < ActiveRecord::Base
	attr_accessible :name, :pending, :done

	#validates :name,  presence: true, length: { maximum: 50 }
end
