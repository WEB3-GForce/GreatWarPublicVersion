require_relative '../../../spec_helper'

describe MeleeAttackComponent do

	let(:basic_melee) {MeleeAttackComponent.new(10)}

	it "should be a subclass of Component" do
		expect(MeleeAttackComponent < Component).to be true
	end

	it "should include ENERGY_COST" do
		expect(MeleeAttackComponent < ENERGY_COST).to be true
	end

	it "should properly initialize itself" do
		melee_comp = MeleeAttackComponent.new(10)
		expect(melee_comp.attack).to eq(10)
	end

	context "when setting attack" do

		it "should set attack to the given attack" do
			basic_melee.attack = 5
			expect(basic_melee.attack).to eq(5)			
			basic_melee.attack = 0
			expect(basic_melee.attack).to eq(0)
		end

		it "should ensure 0 <= attack" do
			basic_melee.attack = -20
			expect(basic_melee.attack).to eq(0)
		end
	end

	it "should have implemented to_s" do
		expect(basic_melee).to respond_to :to_s
		expect(basic_melee.to_s.class).to eq(String)
	end
end
