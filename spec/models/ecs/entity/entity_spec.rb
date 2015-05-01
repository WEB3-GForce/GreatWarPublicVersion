require_relative '../../../spec_helper'

describe Entity do

  it "should be a subclass of string" do
    expect(Entity < String).to be true
  end

  it "should produce uuid's when initialized" do
    entity1 = Entity.new
    entity2 = Entity.new
    expect(entity1).to_not eq(entity2)
  end

  it "should produce an entity with a debug id" do
    entity0 = Entity.debug_entity
    entity1 = Entity.debug_entity
    expect(entity0.include?("entity#")).to be true
    expect(entity1.include?("entity#")).to be true
    expect(entity0).to_not eq(entity1)
  end

  it "should initialize with string arg" do
    entity = Entity.new "entity#0"
    expect(entity).to eq "entity#0"
  end
end
