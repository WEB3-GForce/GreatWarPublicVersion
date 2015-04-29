require_relative '../../../spec_helper'

class Test
	include ENERGY_COST
end

describe ENERGY_COST do

	let(:energy_user) {Test.new}

	it "should be able to set energy_cost" do
		energy_user.energy_cost = 10
		expect(energy_user.energy_cost).to eq(10)
	end

	it "should ensure energy_cost is set to be >= 0" do
		energy_user.energy_cost = -10
		expect(energy_user.energy_cost).to eq(0)
	end
end
