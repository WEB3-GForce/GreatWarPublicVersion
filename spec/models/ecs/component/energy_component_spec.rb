require_relative '../../../spec_helper'

describe EnergyComponent do

	let(:basic_energy) {EnergyComponent.new(10)}

	it "should be a subclass of Component" do
		expect(EnergyComponent < Component).to be true
	end

	context "when initializing" do

		it "should succeed when given only max_energy" do
			energy_comp = EnergyComponent.new(10)
			expect(energy_comp.cur_energy).to eq(10)
			expect(energy_comp.max_energy).to eq(10)
		end

		it "should succeed when given max_energy and cur_energy" do
			energy_comp = EnergyComponent.new(20, 10)
			expect(energy_comp.cur_energy).to eq(10)
			expect(energy_comp.max_energy).to eq(20)
		end

		it "should ensure max_health > 0 and cur_health > 0" do
			energy_comp = EnergyComponent.new(-10, -10)
			expect(energy_comp.cur_energy).to eq(0)
			expect(energy_comp.max_energy).to eq(0)
		end
	end

	context "when setting max_energy" do

		it "should set max_energy to the given movement" do
			basic_energy.max_energy = 5
			expect(basic_energy.max_energy).to eq(5)			
			basic_energy.max_energy = 0
			expect(basic_energy.max_energy).to eq(0)
		end

		it "should ensure 0 <= max_energy" do
			basic_energy.max_energy = -20
			expect(basic_energy.max_energy).to eq(0)
		end
	end

	context "when setting cur_energy" do

		it "should set cur_energy to the given movement" do
			basic_energy.cur_energy = 5
			expect(basic_energy.cur_energy).to eq(5)			
			basic_energy.reset
			expect(basic_energy.max_energy).to eq(10)
			expect(basic_energy.cur_energy).to eq(basic_energy.max_energy)
		end


		it "should ensure 0 <= cur_energy" do
			basic_energy.cur_energy = -20
			expect(basic_energy.cur_energy).to eq(0)
		end
	end


	context "when calling reset" do

		it "should properly reset cur_energy" do
			basic_energy.cur_energy = 5
			expect(basic_energy.cur_energy).to eq(5)			
			basic_energy.cur_energy = 0
			expect(basic_energy.cur_energy).to eq(0)
		end

	end


	context "when cur_energy > 0" do

		it "should be energized" do
			expect(basic_energy.energized?).to be true
		end
	end

	context "when cur_energy == 0" do

		it "should not be energized" do
			basic_energy.cur_energy = 0
			expect(basic_energy.energized?).to be false
		end
	end


	it "should have implemented to_s" do
		expect(basic_energy).to respond_to :to_s
		expect(basic_energy.to_s.class).to eq(String)
	end
end
