require_relative '../../../spec_helper'

def debug_infantry(entity_manager, owner)
  return EntityFactory.create_entity(entity_manager,
                                     [PieceComponent.infantry,
                                      HealthComponent.new(10),
                                      EnergyComponent.new(10),
                                      MotionComponent.new(5),
                                      MeleeAttackComponent.new(10),
                                      RangeAttackComponent.new(10, 1, 4),
                                      OwnedComponent.new(owner)])
end

describe TurnSystem do

  let(:manager)       {EntityManager.new(3, 3)}
  let(:human1)        {EntityFactory.human_player(manager, "Gates")}    
  let(:human2)        {EntityFactory.human_player(manager, "Jobs")}
  let(:turn_entity)   {EntityFactory.turn_entity(manager, [human1, human2])}
  let(:infantry1a)    {debug_infantry(manager, human1)}    
  let(:infantry1b)    {debug_infantry(manager, human1)}
  let(:infantry2a)    {debug_infantry(manager, human2)}
  let(:infantry2b)    {debug_infantry(manager, human2)}

  it "should be a subclass of System" do
    expect(TurnSystem < System).to be true
  end

  context "when calling turn_component" do
    it "should return the entity manager's turn component" do
      manager = EntityManager.new(3, 3)
      human1 = EntityFactory.human_player(manager, "Gates")
      human2 = EntityFactory.human_player(manager, "Jobs")
      turn_entity = EntityFactory.turn_entity(manager, [human1, human2])
      infantry1a = debug_infantry(manager, human1)
      infantry1b = debug_infantry(manager, human1)
      infantry2a = debug_infantry(manager, human2)
      infantry2b = debug_infantry(manager, human2)

      result = TurnSystem.turn_component(manager)
      expect(result).to eq manager[turn_entity][TurnComponent].first
    end
  end

  context "when calling current_turn" do
    it "should return the current player's turn" do
      manager = EntityManager.new(3, 3)
      human1 = EntityFactory.human_player(manager, "Gates")
      human2 = EntityFactory.human_player(manager, "Jobs")
      turn_entity = EntityFactory.turn_entity(manager, [human1, human2])
      infantry1a = debug_infantry(manager, human1)
      infantry1b = debug_infantry(manager, human1)
      infantry2a = debug_infantry(manager, human2)
      infantry2b = debug_infantry(manager, human2)

      result = TurnSystem.current_turn(manager)
      expect(result).to be human1
    end
  end

  context "when calling next_turn" do
    it "should return the next player's turn" do
      manager = EntityManager.new(3, 3)
      human1 = EntityFactory.human_player(manager, "Gates")
      human2 = EntityFactory.human_player(manager, "Jobs")
      turn_entity = EntityFactory.turn_entity(manager, [human1, human2])
      infantry1a = debug_infantry(manager, human1)
      infantry1b = debug_infantry(manager, human1)
      infantry2a = debug_infantry(manager, human2)
      infantry2b = debug_infantry(manager, human2)

      result = TurnSystem.next_turn(manager)
      expect(result).to be human2
    end
  end

  context "when calling current_turn_entity?" do
    it "should return true if entity belongs to current player" do
      manager = EntityManager.new(3, 3)
      human1 = EntityFactory.human_player(manager, "Gates")
      human2 = EntityFactory.human_player(manager, "Jobs")
      turn_entity = EntityFactory.turn_entity(manager, [human1, human2])
      infantry1a = debug_infantry(manager, human1)
      infantry1b = debug_infantry(manager, human1)
      infantry2a = debug_infantry(manager, human2)
      infantry2b = debug_infantry(manager, human2)

      result = TurnSystem.current_turn_entity?(manager, infantry1a)
      expect(result).to be true
    end

    it "should return false if entity doesn't belong to current player" do
      manager = EntityManager.new(3, 3)
      human1 = EntityFactory.human_player(manager, "Gates")
      human2 = EntityFactory.human_player(manager, "Jobs")
      turn_entity = EntityFactory.turn_entity(manager, [human1, human2])
      infantry1a = debug_infantry(manager, human1)
      infantry1b = debug_infantry(manager, human1)
      infantry2a = debug_infantry(manager, human2)
      infantry2b = debug_infantry(manager, human2)

      result = TurnSystem.current_turn_entity?(manager, infantry2a)
      expect(result).to be false
    end
  end

  context "when calling current_turn_entities_each" do
    it "should return entities belonging to the current player" do
      manager = EntityManager.new(3, 3)
      human1 = EntityFactory.human_player(manager, "Gates")
      human2 = EntityFactory.human_player(manager, "Jobs")
      turn_entity = EntityFactory.turn_entity(manager, [human1, human2])
      infantry1a = debug_infantry(manager, human1)
      infantry1b = debug_infantry(manager, human1)
      infantry2a = debug_infantry(manager, human2)
      infantry2b = debug_infantry(manager, human2)

      TurnSystem.current_turn_entities_each(manager) { |e|
        owner = manager[e][OwnedComponent].first.owner
        expect(owner).to be human1
      }
    end
  end

  context "when calling current_turn_entities" do
    it "should return all entities belonging to the current player" do
      manager = EntityManager.new(3, 3)
      human1 = EntityFactory.human_player(manager, "Gates")
      human2 = EntityFactory.human_player(manager, "Jobs")
      turn_entity = EntityFactory.turn_entity(manager, [human1, human2])
      infantry1a = debug_infantry(manager, human1)
      infantry1b = debug_infantry(manager, human1)
      infantry2a = debug_infantry(manager, human2)
      infantry2b = debug_infantry(manager, human2)

      result = TurnSystem.current_turn_entities(manager)
      expect(result.to_set).to eq [infantry1a, infantry1b].to_set
    end
  end

  context "when calling update" do 
    it "should change the current player to the next" do
      manager = EntityManager.new(3, 3)
      human1 = EntityFactory.human_player(manager, "Gates")
      human2 = EntityFactory.human_player(manager, "Jobs")
      turn_entity = EntityFactory.turn_entity(manager, [human1, human2])
      infantry1a = debug_infantry(manager, human1)
      infantry1b = debug_infantry(manager, human1)
      infantry2a = debug_infantry(manager, human2)
      infantry2b = debug_infantry(manager, human2)

      result = TurnSystem.update(manager)
      expect(result).to eq ["turn", human2]

      turn = manager[turn_entity][TurnComponent].first.current_turn
      expect(turn).to be human2
    end

    it "should replenish entity energies for current player" do
      manager = EntityManager.new(3, 3)
      human1 = EntityFactory.human_player(manager, "Gates")
      human2 = EntityFactory.human_player(manager, "Jobs")
      turn_entity = EntityFactory.turn_entity(manager, [human1, human2])
      infantry1a = debug_infantry(manager, human1)
      infantry1b = debug_infantry(manager, human1)
      infantry2a = debug_infantry(manager, human2)
      infantry2b = debug_infantry(manager, human2)

      manager[infantry1a][EnergyComponent].first.cur_energy = 0
      manager[infantry1b][EnergyComponent].first.cur_energy = 0

      result = TurnSystem.update(manager)
      expect(result).to eq ["turn", human2]
      
      energy1 = manager[infantry1a][EnergyComponent].first
      energy2 = manager[infantry1b][EnergyComponent].first
      expect(energy1.cur_energy).to be energy1.max_energy
      expect(energy2.cur_energy).to be energy2.max_energy
    end

    it "should not change entity energies of other players" do
      manager = EntityManager.new(3, 3)
      human1 = EntityFactory.human_player(manager, "Gates")
      human2 = EntityFactory.human_player(manager, "Jobs")
      turn_entity = EntityFactory.turn_entity(manager, [human1, human2])
      infantry1a = debug_infantry(manager, human1)
      infantry1b = debug_infantry(manager, human1)
      infantry2a = debug_infantry(manager, human2)
      infantry2b = debug_infantry(manager, human2)

      manager[infantry2a][EnergyComponent].first.cur_energy = 0
      manager[infantry2b][EnergyComponent].first.cur_energy = 0

      result = TurnSystem.update(manager)
      expect(result).to eq ["turn", human2]
      
      energy1 = manager[infantry2a][EnergyComponent].first
      energy2 = manager[infantry2b][EnergyComponent].first
      expect(energy1.cur_energy).to be 0
      expect(energy2.cur_energy).to be 0
    end
  end
end
