require_relative '../../../spec_helper'

describe PieceComponent do

  it "should be a subclass of Component" do
    expect(PieceComponent < Component).to be true
  end

  it "should properly initialize itself" do
    unit_comp = PieceComponent.new("test")
    expect(unit_comp.type).to eq("test")
  end

  it "should have an infantry piece" do
    expect(PieceComponent.infantry.type).to eq(:infantry)
  end

  it "should have a machine_gun piece" do
    expect(PieceComponent.machine_gun.type).to eq(:machine_gun)
  end

  it "should have a artillery piece" do
    expect(PieceComponent.artillery.type).to eq(:artillery)
  end

  it "should have a command_bunker piece" do
    expect(PieceComponent.command_bunker.type).to eq(:command_bunker)
  end

  it "should have a working to_s" do
    expect(PieceComponent.command_bunker.to_s.class).to eq(String)
  end
end
