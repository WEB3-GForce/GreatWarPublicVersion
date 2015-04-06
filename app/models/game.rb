class Game < ActiveRecord::Base
	attr_accessor :name, :pending, :done
end
