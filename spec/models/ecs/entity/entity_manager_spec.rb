require_relative '../../../spec_helper'

describe EntityManager do

	let(:manager) {EntityManager.new}
	let(:entity)  {Entity.new}
	let(:entity2) {Entity.new}
	let(:entity3) {Entity.new}
	let(:ai1)     {AIComponent.new}
	let(:ai2)     {AIComponent.new}
	let(:human1)  {HumanComponent.new}
	let(:human2)  {HumanComponent.new}
	let(:answer_bag)  {ComponentBag.new}

	it "should be a subclass of Hash" do
		expect(EntityManager < Hash).to be true
	end

	context "when accessing a new key" do

		it "should create a new ComponentBag" do
			expect(manager[entity]).to eq(ComponentBag.new)
			expect(manager[entity]).to eq(ComponentBag.new)
		end
	end

	context "when accessing an old key" do

		it "should return the stored array" do
			answer_bag[AIComponent].push(ai1).push(ai2)
			answer_bag[HumanComponent].push(human1).push(human2)

			manager[entity][AIComponent].push(ai1).push(ai2)
			manager[entity][HumanComponent].push(human1).push(human2)
			expect(manager[entity]).to eq(answer_bag)
		end
	end

	context "when add_component is accessing a new key" do

		it "should create a new ComponentBag" do
			answer_bag[AIComponent].push(ai1)
			manager.add_component(entity, ai1)
			expect(manager[entity]).to eq(answer_bag)
		end
	end

	context "when add_component is accessing an old key" do

		it "should add to the existing ComponentBag" do
			answer_bag[AIComponent].push(ai1).push(ai2)
			manager.add_component(entity, ai1)
			manager.add_component(entity, ai2)
			expect(manager[entity]).to eq(answer_bag)
		end
	end

	context "when get_components is accessing a new key" do

		it "should return a new, empty array" do
			result = manager.get_components(entity, AIComponent)
			expect(result).to eq([])
		end
	end

	context "when get_component is accessing an old key" do

		it "should return the existing ComponentBag" do
			manager.add_component(entity, ai1)
			manager.add_component(entity, ai2)
			result = manager.get_components(entity, AIComponent)
			expect(result).to eq([ai1, ai2])
		end
	end

	context "when calling get_entities_with_components" do

		it "should return the proper entities" do
			manager.add_component(entity, ai1)
			manager.add_component(entity, human1)
			manager.add_component(entity2, ai2)
			manager.add_component(entity3, human2)

			result = manager.get_entities_with_components(AIComponent)
			expect(result).to eq([entity, entity2])

			result = manager.get_entities_with_components(HumanComponent)
			expect(result).to eq([entity, entity3])

			result = manager.get_entities_with_components(AIComponent, HumanComponent)
			expect(result).to eq([entity])
		end

		it "should not create new entries in ComponentBag" do
			manager.add_component(entity, ai1)
			manager.add_component(entity2, ai2)
			manager.add_component(entity3, ai1)

			result = manager.get_entities_with_components(HumanComponent)
			expect(result).to eq([])
			expect(manager[entity].has_key? HumanComponent).to be false
			expect(manager[entity2].has_key? HumanComponent).to be false
			expect(manager[entity3].has_key? HumanComponent).to be false
		end

		it "should not include entities with empty arrays" do
			manager.get_components(entity, HumanComponent)
			manager.get_components(entity2, HumanComponent)
			manager.get_components(entity3, HumanComponent)

			result = manager.get_entities_with_components(HumanComponent)
			expect(result).to eq([])
		end
	end


	context "when calling each_entity" do

		it "should return the proper entities" do
			manager.add_component(entity, ai1)
			manager.add_component(entity, human1)
			manager.add_component(entity2, ai2)
			manager.add_component(entity3, human2)

			manager.each_entity(AIComponent) { |entity|
				expect(entity).to_not eq(entity3)
			}

			manager.each_entity(HumanComponent) { |entity|
				expect(entity).to_not eq(entity2)
			}

			manager.each_entity(AIComponent, HumanComponent) { |entity|
				expect(entity).to_not eq(entity2)
				expect(entity).to_not eq(entity3)
			}
		end

		it "should not create new entries in ComponentBag" do
			manager.add_component(entity, ai1)
			manager.add_component(entity2, ai2)
			manager.add_component(entity3, ai1)

			manager.each_entity(HumanComponent) {}

			expect(manager[entity].has_key? HumanComponent).to be false
			expect(manager[entity2].has_key? HumanComponent).to be false
			expect(manager[entity3].has_key? HumanComponent).to be false
		end

		it "should not include entities with empty arrays" do
			manager.get_components(entity, HumanComponent)
			manager.get_components(entity2, HumanComponent)
			manager.get_components(entity3, HumanComponent)

			manager.each_entity(HumanComponent) {|_,_|
				fail "There should be no matches"
			}
		end
	end

	it "should have implemented to_s" do
		manager.add_component(entity, ai1)
		manager.add_component(entity2, ai1)
		manager.add_component(entity3, ai2)
		expect(manager).to respond_to :to_s
		expect(manager.to_s.class).to eq(String)
	end
end
