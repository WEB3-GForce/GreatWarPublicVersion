require_relative '../../../spec_helper'

describe TurnSystem do

	it "should be a subclass of System" do
		expect(TurnSystem < System).to be true
	end

end
