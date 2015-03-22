require_relative '../../../spec_helper'

describe MotionComponent do

	let(:basic_motion) {MotionComponent.new(10)}

	it "should be a subclass of Component" do
		expect(MotionComponent < Component).to be true
	end

	it "should include USES_ENERGY" do
		expect(MotionComponent < USES_ENERGY).to be true
	end
	
	context "when initializing" do

		it "should succeed when given max_movement" do
			motion_comp = MotionComponent.new(10)
			expect(motion_comp.max_movement).to eq(10)
			expect(motion_comp.energy_cost).to eq(1)
		end

		it "should succeed when given max_movement and energy_cost" do
			motion_comp = MotionComponent.new(20, 2)
			expect(motion_comp.max_movement).to eq(20)
			expect(motion_comp.energy_cost).to eq(2)
		end

		it "should ensure max_health > 0" do
			motion_comp = MotionComponent.new(-10, -10)
			expect(motion_comp.max_movement).to eq(0)
		end
	end

	context "when setting max_movement" do

		it "should set max_movement to the given movement" do
			basic_motion.max_movement = 5
			expect(basic_motion.max_movement).to eq(5)			
			basic_motion.max_movement = 0
			expect(basic_motion.max_movement).to eq(0)
		end

		it "should ensure 0 <= max_movement" do
			basic_motion.max_movement = -20
			expect(basic_motion.max_movement).to eq(0)
		end
	end

	context "when ,ax_movement > 0" do

		it "should be able to move" do
			expect(basic_motion.can_move?).to be true
		end
	end

	context "when max_movement == 0" do

		it "should not be able to move" do
			basic_motion.max_movement = 0
			expect(basic_motion.can_move?).to be false
		end
	end


	it "should have implemented to_s" do
		expect(basic_motion).to respond_to :to_s
		expect(basic_motion.to_s.class).to eq(String)
	end
end
