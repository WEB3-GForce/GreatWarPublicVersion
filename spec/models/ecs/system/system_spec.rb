require_relative '../../../spec_helper'

describe System do

	it "should have implemented to_s" do
		system = System.new
		expect(system).to respond_to :to_s	
		expect(system.to_s.class).to eq(String)
	end
end
