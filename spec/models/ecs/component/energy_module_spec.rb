require_relative '../../../spec_helper'

class Test
	include USES_ENERGY
end

describe USES_ENERGY do

	let(:energy_user) {Test.new}

	it "should be able to set energy_cost" do
		energy_user.energy_cost = 10
		expect(energy_user.energy_cost).to eq(10)
	end
end
