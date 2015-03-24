require_relative '../../../spec_helper'

describe RangeAttackComponent do

	let(:basic_rattack) {RangeAttackComponent.new(10, 3, 7)}

	it "should be a subclass of Component" do
		expect(RangeAttackComponent < Component).to be true
	end

	it "should include ENERGY_COST" do
		expect(RangeAttackComponent < ENERGY_COST).to be true
	end

	context "when initializing" do

		it "should initialize itself properly" do
			rattack_comp = RangeAttackComponent.new(10, 3, 7)
			expect(rattack_comp.attack).to eq(10)
			expect(rattack_comp.min_range).to eq(3)
			expect(rattack_comp.max_range).to eq(7)
		end

		it "should ensure attack >= 0" do
			rattack_comp = RangeAttackComponent.new(-10, 3, 7)
			expect(rattack_comp.attack).to eq(0)
		end

		it "should ensure min_range <= max_range" do
			rattack_comp = RangeAttackComponent.new(10, 7, 3)
			expect(rattack_comp.min_range).to eq(3)
			expect(rattack_comp.max_range).to eq(3)
		end
	end

	context "when setting attack" do

		it "should set attack to the given attack" do
			basic_rattack.attack = 5
			expect(basic_rattack.attack).to eq(5)			
			basic_rattack.attack = 0
			expect(basic_rattack.attack).to eq(0)
		end

		it "should ensure 0 <= attack" do
			basic_rattack.attack = -20
			expect(basic_rattack.attack).to eq(0)
		end
	end
	
	context "when setting min_range" do
	
		it "should set min_range to the given new min_range" do
			basic_rattack.min_range = 5
			expect(basic_rattack.min_range).to eq(5)
			expect(basic_rattack.max_range).to eq(7)
		end

		it "should ensure 0 <= min_range" do
			basic_rattack.min_range = -20 
			expect(basic_rattack.min_range).to eq(0)
			expect(basic_rattack.max_range).to eq(7)
		end

		it "should ensure max_range >= min_range" do
			basic_rattack.min_range = 10 
			expect(basic_rattack.min_range).to eq(10)
			expect(basic_rattack.max_range).to eq(10)
		end
	end

	context "when setting max_range" do
	
		it "should set max_range to the given new max_range" do
			basic_rattack.max_range = 10
			expect(basic_rattack.min_range).to eq(3)
			expect(basic_rattack.max_range).to eq(10)
		end

		it "should ensure 0 <= max_range" do
			basic_rattack.max_range = -20 
			expect(basic_rattack.min_range).to eq(0)
			expect(basic_rattack.max_range).to eq(0)
		end

		it "should ensure min_range =< max_range" do
			basic_rattack.max_range = 2 
			expect(basic_rattack.min_range).to eq(2)
			expect(basic_rattack.max_range).to eq(2)
		end
	end

	it "should have implemented to_s" do
		expect(basic_rattack).to respond_to :to_s
		expect(basic_rattack.to_s.class).to eq(String)
	end
end
