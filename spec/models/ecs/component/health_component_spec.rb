require_relative '../../../spec_helper'

describe HealthComponent do

	let(:basic_health) {HealthComponent.new(10)}

	it "should be a subclass of Component" do
		expect(HealthComponent < Component).to be true
	end

	context "when initializing" do

		it "should succeed when given only max_health" do
			health_comp = HealthComponent.new(10)
			expect(health_comp.cur_health).to eq(10)
			expect(health_comp.max_health).to eq(10)
		end

		it "should succeed when given max_health and cur_health" do
			health_comp = HealthComponent.new(20, 10)
			expect(health_comp.cur_health).to eq(10)
			expect(health_comp.max_health).to eq(20)
		end

		it "should ensure max_health > 0 and cur_health > 0" do
			health_comp = HealthComponent.new(-10, -10)
			expect(health_comp.cur_health).to eq(0)
			expect(health_comp.max_health).to eq(0)
		end
	
		it "should ensure cur_health <= max_health" do
			health_comp = HealthComponent.new(10, 20)
			expect(health_comp.cur_health).to eq(10)
			expect(health_comp.max_health).to eq(10)
		end
	end

	context "when setting cur_health" do

		it "should set cur_health to the given health" do
			basic_health.cur_health = 5
			expect(basic_health.cur_health).to eq(5)			
			basic_health.cur_health = 0
			expect(basic_health.cur_health).to eq(0)
		end


		it "should ensure 0 <= cur_health" do
			basic_health.cur_health = -20
			expect(basic_health.cur_health).to eq(0)
		end
		
		it "should ensure cur_health <= max_health" do
			basic_health.cur_health = 15
			expect(basic_health.cur_health).to eq(10)
		end
	end
	
	context "when setting max_health" do
	
		it "should increase max_health and cur_health appropriately" do
			basic_health.max_health = 20
			expect(basic_health.cur_health).to eq(20)
			expect(basic_health.max_health).to eq(20)
		end

		it "should ensure 0 <= max_health and 0 <= cur_health" do
			basic_health.max_health = -10
			expect(basic_health.cur_health).to eq(0)
			expect(basic_health.max_health).to eq(0)
		end

		context "and max_health increases" do
		
			it "should maintain the diff between max_health and cur_health" do
				health_comp = HealthComponent.new(10, 5)
				health_comp.max_health = 15
				expect(health_comp.cur_health).to eq(10)
				expect(health_comp.max_health).to eq(15)
			end
		end

		context "and max_health decreases" do
		
			it "should keep cur_health the same" do
				health_comp = HealthComponent.new(10, 5)
				health_comp.max_health = 7
				expect(health_comp.cur_health).to eq(5)
				expect(health_comp.max_health).to eq(7)
			end
		end
	end

	context "when cur_health > 0" do

		it "should be alive" do
			expect(basic_health.alive?).to be true
		end
	end

	context "when cur_health == 0" do

		it "should be dead" do
			basic_health.cur_health = 0
			expect(basic_health.alive?).to be false
		end
	end

	it "should have implemented to_s" do
		expect(basic_health).to respond_to :to_s
		expect(basic_health.to_s.class).to eq(String)
	end
end
