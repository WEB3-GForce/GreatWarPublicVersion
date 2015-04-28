require_relative '../../../spec_helper'

describe SpriteComponent do

    let(:test) {SpriteComponent.new(112)}

    it "should be a subclass of Component" do
        expect(SpriteComponent < Component).to be true
    end

    it "should properly initialize itself" do
        expect(test.id).to eq(112)
    end

    it "should have implemented to_s" do
        expect(test).to respond_to :to_s
        expect(test.to_s.class).to eq(String)
    end
end
