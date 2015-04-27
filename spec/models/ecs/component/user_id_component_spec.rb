require_relative '../../../spec_helper'

describe UserIdComponent do

	let(:basic_user) {UserIdComponent.new(192, "red", "123")}

	it "should be a subclass of Component" do
		expect(UserIdComponent < Component).to be true
	end

	it "should properly initialize itself" do
		user_comp = UserIdComponent.new(10, "channel", "blue")
		expect(user_comp.id).to eq(10)
		expect(user_comp.faction).to eq("blue")
		expect(user_comp.channel).to eq("channel")
	end

	it "should have implemented to_s" do
		expect(basic_user).to respond_to :to_s
		expect(basic_user.to_s.class).to eq(String)
	end
end
