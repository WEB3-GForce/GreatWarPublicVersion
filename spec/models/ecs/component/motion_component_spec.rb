require_relative '../../../spec_helper'

describe MotionComponent do

	let(:basicMotion) {MotionComponent.new(10)}

	context "when initializing" do

		it "should succeed when given only base_movement" do
			motionComp = MotionComponent.new(10)
			expect(motionComp.cur_movement).to eq(10)
			expect(motionComp.base_movement).to eq(10)
		end

		it "should succeed when given base_movement and cur_movement" do
			motionComp = MotionComponent.new(20, 10)
			expect(motionComp.cur_movement).to eq(10)
			expect(motionComp.base_movement).to eq(20)
		end

		it "should ensure max_health > 0 and cur_health > 0" do
			motionComp = MotionComponent.new(-10, -10)
			expect(motionComp.cur_movement).to eq(0)
			expect(motionComp.base_movement).to eq(0)
		end
	end

	context "when setting base_movement" do

		it "should set base_movement to the given movement" do
			basicMotion.base_movement = 5
			expect(basicMotion.base_movement).to eq(5)			
			basicMotion.base_movement = 0
			expect(basicMotion.base_movement).to eq(0)
		end

		it "should ensure 0 <= base_movement" do
			basicMotion.base_movement = -20
			expect(basicMotion.base_movement).to eq(0)
		end
	end

	context "when setting cur_movement" do

		it "should set cur_movement to the given movement" do
			basicMotion.cur_movement = 5
			expect(basicMotion.cur_movement).to eq(5)			
			basicMotion.cur_movement = 0
			expect(basicMotion.cur_movement).to eq(0)
		end


		it "should ensure 0 <= cur_movement" do
			basicMotion.cur_movement = -20
			expect(basicMotion.cur_movement).to eq(0)
		end
	end

	context "when cur_movement > 0" do

		it "should be able to move" do
			expect(basicMotion.can_move?).to be true
		end
	end

	context "when cur_movement == 0" do

		it "should not be able to move" do
			basicMotion.cur_movement = 0
			expect(basicMotion.can_move?).to be false
		end
	end


	it "should have implemented to_s" do
		expect(basicMotion).to respond_to :to_s
		expect(basicMotion.to_s.class).to eq(String)
	end
end
