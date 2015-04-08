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
end
