require_relative '../../../spec_helper'

describe KillSystem do

	let(:manager)    {EntityManager.new(3, 3)}
	let(:human1)     {EntityFactory.human_player(manager, "David")}
	let(:infantry)   {EntityFactory.infantry(manager, human1)}
	let(:flatland)   {EntityFactory.flatland_square(manager)}
	let(:row)        {1}
	let(:col)        {1}

	def setup
		manager.add_component(flatland,
				      PositionComponent.new(row, col))
		manager.board[row][col] = [flatland, []]
	end

	it "should be a subclass of System" do
		expect(KillSystem < System).to be true
	end
	
	context "when calling update" do
	
		it "should return [] if the entity is not damageable" do
			result = KillSystem.update(manager, flatland)
			expect(result).to eq []
		end
		
		it "should return [] if the entity is still alive" do
			result = KillSystem.update(manager, infantry)
			expect(result).to eq []
		end

		context "when the entity is dead" do
			it "should remove the entity" do
				manager[infantry].delete OwnedComponent
				health = manager.get_components(infantry, HealthComponent).first
				health.cur_health = 0
				result = KillSystem.update(manager, infantry)
				expect(result).to eq [["kill", infantry, false, nil]]
			end

			it "should remove the entity from the board" do
				setup()
				manager.board[row][col][1].push infantry
				manager.add_component(infantry,
					      PositionComponent.new(row, col))
				manager[infantry].delete OwnedComponent
				health = manager.get_components(infantry, HealthComponent).first
				health.cur_health = 0
				result = KillSystem.update(manager, infantry)
				expect(result).to eq [["kill", infantry, true, nil]]
			end

			it "should record the entity's owner" do
				setup()
				manager.board[row][col][1].push infantry
				manager.add_component(infantry,
					      PositionComponent.new(row, col))
				health = manager.get_components(infantry, HealthComponent).first
				health.cur_health = 0
				result = KillSystem.update(manager, infantry)
				expect(result).to eq [["kill", infantry, true, human1]]
			end
		end
	end
end
