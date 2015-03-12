require_relative '../../../spec_helper'

describe UnitComponent do

	it "should be a subclass of Component" do
		expect(UnitComponent < Component).to be true
	end

	it "should properly initialize itself" do
		unit_comp = UnitComponent.new("test")
		expect(unit_comp.type).to eq("test")
	end

	it "should have an infantry unit" do
		expect(UnitComponent.infantry.type).to eq(:infantry)
	end

	it "should have an machine_gun unit" do
		expect(UnitComponent.machine_gun.type).to eq(:machine_gun)
	end

	it "should have an artillery unit" do
		expect(UnitComponent.artillery.type).to eq(:artillery)
	end
end
