#require_relative '../controllers/socket_controller.rb'

module GamasHelper

	def game_pending?(game)
		game.pending
	end

	def game_done?(game)
		game.done
	end

	def assign_game_to_current_user(game)
		user = current_user
		user.game = game.id
		user.save!
	end

	def players_in_game(game)
		@players = User.where(:game.to_s => game.id)
		return @players
	end

	def is_game_full?(game)
		game.players == game.limit
	end
	# TODO:
	# There is a bug when the host leaves the game while other people are in it
	def leave_game
		user = current_user
		game = Gama.find(user.game)
		user.game = 0
		user.save!

		game.update_attribute(:pending, true)
		user.update_attribute(:host, false)
		game.update_attributes(:players, game.players - 1)
	end
	
	def is_current_user_host?(game)
		user = current_user
		return user.host && (user.game == game.id)
	end
	
	def start_game(players, game)
		if (SocketController.init_game(players, game.id))
			redirect_to "/play"
			
		end
	end

end
