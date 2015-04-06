module GamesHelper
	def game_pending?(game)
		game.pending
	end

	def game_done?(game)
		game.done
	end
end
