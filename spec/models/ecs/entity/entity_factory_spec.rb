require_relative '../../../spec_helper'

def place_top_left_helper(manager, army, owner)
	(0..4).each { |row|
		(0..4).each { |col|
			unit = army.shift
			expect(manager.board[row][col][1]).to eq([unit])
			expect(manager[unit][OwnedComponent][0].owner).to eq(owner)
		}
	}
	expect(army.size).to eq(0)
end

def place_bottom_left_helper(manager, army, owner)
	max_row = manager.row - 1
	max_row.step(max_row-4, -1).each { |row|
		(0..4).each { |col|
			unit = army.shift
			expect(manager.board[row][col][1]).to eq([unit])
			expect(manager[unit][OwnedComponent][0].owner).to eq(owner)
		}
	}
	expect(army.size).to eq(0)
end

def place_top_right_helper(manager, army, owner)
	max_col = manager.col - 1
	(0..4).each { |row|
		max_col.step(max_col-4, -1).each { |col|
			unit = army.shift
			expect(manager.board[row][col][1]).to eq([unit])
			expect(manager[unit][OwnedComponent][0].owner).to eq(owner)
		}
	}
	expect(army.size).to eq(0)
end

def place_bottom_right_helper(manager, army, owner)
	max_row = manager.row - 1
	max_col = manager.col - 1
	max_row.step(max_row-4, -1).each { |row|
		max_col.step(max_col-4, -1).each { |col|
			unit = army.shift
			expect(manager.board[row][col][1]).to eq([unit])
			expect(manager[unit][OwnedComponent][0].owner).to eq(owner)
		}
	}
	expect(army.size).to eq(0)
end

describe EntityFactory do

	let(:manager) {EntityManager.new(15, 15)}
	let(:ai)      {AIComponent.new}
	let(:ai)      {AIComponent.new}
	let(:human)   {HumanComponent.new}

	it "should create a new entity" do
		entity = EntityFactory.create_entity(manager, [ai, human])
		expect(manager[entity][AIComponent]).to eq([ai])
		expect(manager[entity][HumanComponent]).to eq([human])
	end

	it "should create a new flatland square" do
		entity = EntityFactory.flatland_square(manager)
		expect(manager[entity][TerrainComponent][0]).to eq(TerrainComponent.flatland)
		expect(manager[entity][OccupiableComponent].size).to eq(1)
		expect(manager[entity][ImpassableComponent].size).to eq(0)
	end

	it "should create a new mountain square" do
		entity = EntityFactory.mountain_square(manager)
		expect(manager[entity][TerrainComponent][0]).to eq(TerrainComponent.mountain)
		expect(manager[entity][ImpassableComponent].size).to eq(1)
		expect(manager[entity][OccupiableComponent].size).to eq(0)
	end

	it "should create a new hill square" do
		entity = EntityFactory.hill_square(manager)
		expect(manager[entity][TerrainComponent][0]).to eq(TerrainComponent.hill)
		expect(manager[entity][OccupiableComponent].size).to eq(1)
		expect(manager[entity][ImpassableComponent].size).to eq(0)
	end

	it "should create a new trench square" do
		entity = EntityFactory.trench_square(manager)
		expect(manager[entity][TerrainComponent][0]).to eq(TerrainComponent.trench)
		expect(manager[entity][OccupiableComponent].size).to eq(1)
		expect(manager[entity][ImpassableComponent].size).to eq(0)
	end

	it "should create a new river square" do
		entity = EntityFactory.river_square(manager)
		expect(manager[entity][TerrainComponent][0]).to eq(TerrainComponent.river)
		expect(manager[entity][ImpassableComponent].size).to eq(0)
		expect(manager[entity][OccupiableComponent].size).to eq(0)
	end

	it "should create a new board with flatland squares" do
		entity = EntityFactory.create_board_basic(manager)
		(0...manager.row).each { |row|
			(0...manager.col).each { |col|
				board_piece = manager.board[row][col]
				expect(board_piece[1]).to eq([])
				
				square = board_piece[0]
				pos_comp = manager[square][PositionComponent][0]
				ter_comp = manager[square][TerrainComponent][0]
				expect(ter_comp).to eq(TerrainComponent.flatland)
				expect(pos_comp.row).to eq(row)
				expect(pos_comp.col).to eq(col)
			}
		}
	end

	it "should create a new human player" do
		entity = EntityFactory.human_player(manager, "David")
		expect(manager[entity][NameComponent][0].name).to eq("David")
		expect(manager[entity][HumanComponent].size).to eq(1)
	end

	it "should create a new ai player" do
		entity = EntityFactory.ai_player(manager, "CPU 1")
		expect(manager[entity][NameComponent][0].name).to eq("CPU 1")
		expect(manager[entity][AIComponent].size).to eq(1)
	end

	it "should create a new turn entity" do
		players = ["Player1", "Player2", "Player3"]
		entity = EntityFactory.turn_entity(manager, players)
		turn_comp = manager[entity][TurnComponent][0]
		expect(turn_comp.current_turn).to eq("Player1")
		
		expect(turn_comp.next_turn).to eq("Player2")
		expect(turn_comp.current_turn).to eq("Player2")

		expect(turn_comp.next_turn).to eq("Player3")
		expect(turn_comp.current_turn).to eq("Player3")

		expect(turn_comp.next_turn).to eq("Player1")
		expect(turn_comp.current_turn).to eq("Player1")
	end

	it "should create a new infantry piece" do
		owner = EntityFactory.human_player(manager, "David")
		entity = EntityFactory.infantry(manager, owner)
		
		unit_comp   = manager[entity][PieceComponent][0]
		health_comp = manager[entity][HealthComponent][0]
		motion_comp = manager[entity][MotionComponent][0]
		melee_comp  = manager[entity][MeleeAttackComponent][0]
		range_comp  = manager[entity][RangeAttackComponent][0]
		owned_comp  = manager[entity][OwnedComponent][0]
		energy_comp  = manager[entity][EnergyComponent][0]
		
		expect(unit_comp.type).to eq(:infantry)
		expect(health_comp.cur_health).to eq(10)
		expect(health_comp.max_health).to eq(10)
		expect(energy_comp.cur_energy).to eq(10)
		expect(energy_comp.max_energy).to eq(10)
		expect(motion_comp.max_movement).to eq(5)
		expect(melee_comp.attack).to eq(10)
		expect(range_comp.attack).to eq(10)
		expect(range_comp.min_range).to eq(1)
		expect(range_comp.max_range).to eq(4)
		expect(owned_comp.owner).to eq(owner)
	end

	it "should create a new machine gun piece" do
		owner = EntityFactory.human_player(manager, "David")
		entity = EntityFactory.machine_gun(manager, owner)
		
		unit_comp   = manager[entity][PieceComponent][0]
		health_comp = manager[entity][HealthComponent][0]
		motion_comp = manager[entity][MotionComponent][0]
		melee_comp  = manager[entity][MeleeAttackComponent][0]
		range_comp  = manager[entity][RangeAttackComponent][0]
		owned_comp  = manager[entity][OwnedComponent][0]
		energy_comp  = manager[entity][EnergyComponent][0]
		
		expect(unit_comp.type).to eq(:machine_gun)
		expect(health_comp.cur_health).to eq(20)
		expect(health_comp.max_health).to eq(20)
		expect(energy_comp.cur_energy).to eq(10)
		expect(motion_comp.max_movement).to eq(3)
		expect(melee_comp.attack).to eq(10)
		expect(range_comp.attack).to eq(10)
		expect(range_comp.min_range).to eq(3)
		expect(range_comp.max_range).to eq(7)
		expect(owned_comp.owner).to eq(owner)
	end

	it "should create a new artillery piece" do
		owner = EntityFactory.human_player(manager, "David")
		entity = EntityFactory.artillery(manager, owner)
		
		unit_comp      = manager[entity][PieceComponent][0]
		health_comp    = manager[entity][HealthComponent][0]
		motion_comp    = manager[entity][MotionComponent][0]
		has_melee_comp = manager[entity].has_key? MeleeAttackComponent
		range_comp     = manager[entity][RangeAttackComponent][0]
		owned_comp     = manager[entity][OwnedComponent][0]
		energy_comp  = manager[entity][EnergyComponent][0]
		
		expect(unit_comp.type).to eq(:artillery)
		expect(health_comp.cur_health).to eq(10)
		expect(health_comp.max_health).to eq(10)
		expect(energy_comp.cur_energy).to eq(10)
		expect(energy_comp.max_energy).to eq(10)
		expect(motion_comp.max_movement).to eq(1)
		expect(has_melee_comp).to be false
		expect(range_comp.attack).to eq(20)
		expect(range_comp.min_range).to eq(5)
		expect(range_comp.max_range).to eq(15)
		expect(owned_comp.owner).to eq(owner)
	end

	it "should create a new command_bunker piece" do
		owner  = EntityFactory.human_player(manager, "David")
		entity = EntityFactory.command_bunker(manager, owner)
		
		unit_comp      = manager[entity][PieceComponent][0]
		health_comp    = manager[entity][HealthComponent][0]
		immunity_comp  = manager[entity][RangeAttackImmunityComponent][0]
		owned_comp     = manager[entity][OwnedComponent][0]
		energy_comp  = manager[entity][EnergyComponent][0]
		
		expect(unit_comp.type).to eq(:command_bunker)
		expect(health_comp.cur_health).to eq(30)
		expect(health_comp.max_health).to eq(30)
		expect(energy_comp.cur_energy).to eq(10)
		expect(energy_comp.max_energy).to eq(10)
		expect(immunity_comp.class).to eq(RangeAttackImmunityComponent)
		expect(owned_comp.owner).to eq(owner)
	end

	it "should create a new army" do
		owner  = EntityFactory.human_player(manager, "David")
		army   = EntityFactory.create_army(manager, owner)
		
		expect(army.size).to eq(25)
		
		expect(manager[army[0]][PieceComponent][0].type).to eq(:command_bunker)
		
		(1..3).each {|i|
			expect(manager[army[i]][PieceComponent][0].type).to eq(:artillery)
		}
		
		(4..10).each {|i|
			expect(manager[army[i]][PieceComponent][0].type).to eq(:machine_gun)
		}
		(11..24).each {|i|
			expect(manager[army[i]][PieceComponent][0].type).to eq(:infantry)
		}
	end

	it "should place a piece on a board" do
		EntityFactory.create_board_basic(manager)
		owner    = EntityFactory.human_player(manager, "David")
		infantry = EntityFactory.infantry(manager, owner)
		
		row = 5
		col = 13
		EntityFactory.place_piece(manager, infantry, row, col)
		
		expect(manager.board[row][col][1]).to eq([infantry])

		pos_comp = manager[infantry][PositionComponent][0]

		expect(pos_comp.row).to eq(row)
		expect(pos_comp.col).to eq(col)
	end

	it "should place an army on the top left corner of the board" do
		EntityFactory.create_board_basic(manager)
		owner  = EntityFactory.human_player(manager, "David")
		army   = EntityFactory.create_army(manager, owner)
		EntityFactory.place_army_top_left(manager, army)
		place_top_left_helper(manager, army, owner)
	end

	it "should place an army on the bottom left corner of the board" do
		EntityFactory.create_board_basic(manager)
		owner  = EntityFactory.human_player(manager, "David")
		army   = EntityFactory.create_army(manager, owner)	
		EntityFactory.place_army_bottom_left(manager, army)
		place_bottom_left_helper(manager, army, owner)
	end

	it "should place an army on the top right corner of the board" do
		EntityFactory.create_board_basic(manager)
		owner  = EntityFactory.human_player(manager, "David")
		army   = EntityFactory.create_army(manager, owner)
		EntityFactory.place_army_top_right(manager, army)
		place_top_right_helper(manager, army, owner)
	end

	it "should place an army on the bottom right corner of the board" do
		EntityFactory.create_board_basic(manager)
		owner  = EntityFactory.human_player(manager, "David")
		army   = EntityFactory.create_army(manager, owner)
		EntityFactory.place_army_bottom_right(manager, army)
		place_bottom_right_helper(manager, army, owner)
	end

	it "should create a new basic game with 1 player" do
		game_bundle = EntityFactory.create_game_basic(manager, ["David"])
		turn_comp   = manager[game_bundle[1]][TurnComponent][0]
		player1     = game_bundle[0][0]
		army1       = game_bundle[2][0...25]
	
		expect(turn_comp.current_turn).to eq(player1)
		expect(turn_comp.next_turn).to eq(player1)
		expect(turn_comp.current_turn).to eq(player1)
		
		expect(manager[player1][NameComponent][0].name).to eq("David")
		
		place_top_left_helper(manager, army1, player1)
	end

	it "should create a new basic game with 2 player" do
		game_bundle = EntityFactory.create_game_basic(manager, ["David", "Charlie"])
		turn_comp   = manager[game_bundle[1]][TurnComponent][0]
		player1     = game_bundle[0][0]
		army1       = game_bundle[2][0...25]
		player2     = game_bundle[0][1]
		army2       = game_bundle[2][25...50]

		expect(turn_comp.current_turn).to eq(player1)
		
		expect(turn_comp.next_turn).to eq(player2)
		expect(turn_comp.current_turn).to eq(player2)

		expect(turn_comp.next_turn).to eq(player1)
		expect(turn_comp.current_turn).to eq(player1)		

		expect(manager[player1][NameComponent][0].name).to eq("David")
		expect(manager[player2][NameComponent][0].name).to eq("Charlie")

		place_top_left_helper(manager, army1, player1)
		place_bottom_right_helper(manager, army2, player2)
	end

	it "should create a new basic game with 3 player" do
		game_bundle = EntityFactory.create_game_basic(manager, ["David", "Charlie", "Jack"])
		turn_comp   = manager[game_bundle[1]][TurnComponent][0]
		player1     = game_bundle[0][0]
		army1       = game_bundle[2][0...25]
		player2     = game_bundle[0][1]
		army2       = game_bundle[2][25...50]
		player3     = game_bundle[0][2]
		army3       = game_bundle[2][50...75]

		expect(turn_comp.current_turn).to eq(player1)
		
		expect(turn_comp.next_turn).to eq(player2)
		expect(turn_comp.current_turn).to eq(player2)

		expect(turn_comp.next_turn).to eq(player3)
		expect(turn_comp.current_turn).to eq(player3)		

		expect(turn_comp.next_turn).to eq(player1)
		expect(turn_comp.current_turn).to eq(player1)		


		expect(manager[player1][NameComponent][0].name).to eq("David")
		expect(manager[player2][NameComponent][0].name).to eq("Charlie")
		expect(manager[player3][NameComponent][0].name).to eq("Jack")

		place_top_left_helper(manager, army1, player1)
		place_bottom_right_helper(manager, army2, player2)
		place_top_right_helper(manager, army3, player3)
	end

	it "should create a new basic game with 4 player" do
		game_bundle = EntityFactory.create_game_basic(manager, ["David", "Charlie", "Jack", "Steve"])
		turn_comp   = manager[game_bundle[1]][TurnComponent][0]
		player1     = game_bundle[0][0]
		army1       = game_bundle[2][0...25]
		player2     = game_bundle[0][1]
		army2       = game_bundle[2][25...50]
		player3     = game_bundle[0][2]
		army3       = game_bundle[2][50...75]
		player4     = game_bundle[0][3]
		army4       = game_bundle[2][75...100]

		expect(turn_comp.current_turn).to eq(player1)
		
		expect(turn_comp.next_turn).to eq(player2)
		expect(turn_comp.current_turn).to eq(player2)

		expect(turn_comp.next_turn).to eq(player3)
		expect(turn_comp.current_turn).to eq(player3)		

		expect(turn_comp.next_turn).to eq(player4)
		expect(turn_comp.current_turn).to eq(player4)		

		expect(turn_comp.next_turn).to eq(player1)
		expect(turn_comp.current_turn).to eq(player1)

		expect(manager[player1][NameComponent][0].name).to eq("David")
		expect(manager[player2][NameComponent][0].name).to eq("Charlie")
		expect(manager[player3][NameComponent][0].name).to eq("Jack")
		expect(manager[player4][NameComponent][0].name).to eq("Steve")

		place_top_left_helper(manager, army1, player1)
		place_bottom_right_helper(manager, army2, player2)
		place_top_right_helper(manager, army3, player3)
		place_bottom_left_helper(manager, army4, player4)
	end
end

