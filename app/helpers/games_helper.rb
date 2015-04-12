module GamesHelper

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
		@players = User.find_by(:game => game.id)
		return @players
	end

	def leave_game
		user = current_user
		game = Game.find(user.game)
		user.game = 0
		user.save!

		game.update_attribute(:pending, true)
	end

end
