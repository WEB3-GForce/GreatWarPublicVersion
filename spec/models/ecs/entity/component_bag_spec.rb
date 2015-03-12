require_relative '../../../spec_helper'

describe ComponentBag do

	let(:bag) {ComponentBag.new}

	it "should be a subclass of Hash" do
		expect(ComponentBag < Hash).to be true
	end

	context "when accessing a new key" do

		it "should create a new array" do
			expect(bag[AIComponent]).to eq([])
			expect(bag[AIComponent]).to eq([])
		end
	end

	context "when accessing an old key" do

		it "should return the stored array" do
			ai1 = AIComponent.new
			ai2 = AIComponent.new
			answer = [ai1, ai2]
			bag[AIComponent].push(ai1).push(ai2)
			expect(bag[AIComponent]).to eq(answer)
		end
	end

	it "should map component classes to an array of class instances" do
		ai_array         = [AIComponent.new, AIComponent.new]
		bag[AIComponent] = ai_array
		expect(bag[AIComponent]).to eq(ai_array)
	end

	it "should have implemented to_s" do
		bag[AIComponent].push(AIComponent.new).push(AIComponent.new)
		expect(bag).to respond_to :to_s
		expect(bag.to_s.class).to eq(String)
	end
end
