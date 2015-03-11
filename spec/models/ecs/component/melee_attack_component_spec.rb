require_relative '../../../spec_helper'

describe MeleeAttackComponent do

	let(:basicMelee) {MeleeAttackComponent.new(10)}

	it "should properly initialize itself" do
		meleeComp = MeleeAttackComponent.new(10)
		expect(meleeComp.attack).to eq(10)
	end

	context "when setting attack" do

		it "should set attack to the given attack" do
			basicMelee.attack = 5
			expect(basicMelee.attack).to eq(5)			
			basicMelee.attack = 0
			expect(basicMelee.attack).to eq(0)
		end

		it "should ensure 0 <= attack" do
			basicMelee.attack = -20
			expect(basicMelee.attack).to eq(0)
		end
	end

	it "should have implemented to_s" do
		expect(basicMelee).to respond_to :to_s
		expect(basicMelee.to_s.class).to eq(String)
	end
end
