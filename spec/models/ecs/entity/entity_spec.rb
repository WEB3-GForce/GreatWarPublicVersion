require_relative '../../../spec_helper'

describe Entity do
	it "should be able to be initialized" do
		entity = Entity.new
		expect(entity).to eq("")
		
		entity = Entity.new("Luke Skywalker")
		expect(entity).to eq("Luke Skywalker")
	end

	it "should be a subclass of string" do
		expect(Entity < String).to be true
	end
end
