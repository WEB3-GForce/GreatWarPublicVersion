require_relative '../../../spec_helper'

describe Entity do

	it "should produce uuid's when initialized" do
		entity1 = Entity.new
		entity2 = Entity.new
		expect(entity1).to_not eq(entity2)
	end

	it "should be a subclass of string" do
		expect(Entity < String).to be true
	end
end
