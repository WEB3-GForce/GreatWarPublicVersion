require_relative '../../../spec_helper'

describe BoostComponent do

	let(:basic_boost) {BoostComponent.new(:test, 2)}

	it "should be a subclass of Component" do
		expect(BoostComponent < Component).to be true
	end

	context "when initializing" do

		it "should set type and boost appropriately." do
			boost_comp = BoostComponent.new(:test, 2)
			expect(boost_comp.type).to eq(:test)
			expect(boost_comp.amount).to eq(2)
		end
	end

	it "should have a defense boost" do
		expect(BoostComponent.defense.type).to eq(:defense)
		expect(BoostComponent.defense.amount).to eq(2)
	end

	it "should have a move_cost boost" do
		expect(BoostComponent.move_cost.type).to eq(:move_cost)
		expect(BoostComponent.move_cost.amount).to eq(2)
	end

	it "should have implemented to_s" do
		expect(basic_boost).to respond_to :to_s
		expect(basic_boost.to_s.class).to eq(String)
		expect(basic_boost.to_s.include? "Boost").to be true
	end


end
