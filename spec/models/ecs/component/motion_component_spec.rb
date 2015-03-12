require_relative '../../../spec_helper'

describe MotionComponent do

	let(:basic_motion) {MotionComponent.new(10)}

	it "should be a subclass of Component" do
		expect(MotionComponent < Component).to be true
	end

	context "when initializing" do

		it "should succeed when given only base_movement" do
			motion_comp = MotionComponent.new(10)
			expect(motion_comp.cur_movement).to eq(10)
			expect(motion_comp.base_movement).to eq(10)
		end

		it "should succeed when given base_movement and cur_movement" do
			motion_comp = MotionComponent.new(20, 10)
			expect(motion_comp.cur_movement).to eq(10)
			expect(motion_comp.base_movement).to eq(20)
		end

		it "should ensure max_health > 0 and cur_health > 0" do
			motion_comp = MotionComponent.new(-10, -10)
			expect(motion_comp.cur_movement).to eq(0)
			expect(motion_comp.base_movement).to eq(0)
		end
	end

	context "when setting base_movement" do

		it "should set base_movement to the given movement" do
			basic_motion.base_movement = 5
			expect(basic_motion.base_movement).to eq(5)			
			basic_motion.base_movement = 0
			expect(basic_motion.base_movement).to eq(0)
		end

		it "should ensure 0 <= base_movement" do
			basic_motion.base_movement = -20
			expect(basic_motion.base_movement).to eq(0)
		end
	end

	context "when setting cur_movement" do

		it "should set cur_movement to the given movement" do
			basic_motion.cur_movement = 5
			expect(basic_motion.cur_movement).to eq(5)			
			basic_motion.cur_movement = 0
			expect(basic_motion.cur_movement).to eq(0)
		end


		it "should ensure 0 <= cur_movement" do
			basic_motion.cur_movement = -20
			expect(basic_motion.cur_movement).to eq(0)
		end
	end

	context "when cur_movement > 0" do

		it "should be able to move" do
			expect(basic_motion.can_move?).to be true
		end
	end

	context "when cur_movement == 0" do

		it "should not be able to move" do
			basic_motion.cur_movement = 0
			expect(basic_motion.can_move?).to be false
		end
	end


	it "should have implemented to_s" do
		expect(basic_motion).to respond_to :to_s
		expect(basic_motion.to_s.class).to eq(String)
	end
end
