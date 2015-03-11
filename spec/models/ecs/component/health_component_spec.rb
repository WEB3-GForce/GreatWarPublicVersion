require_relative '../../../spec_helper'

describe HealthComponent do

	let(:basicHealth) {HealthComponent.new(10)}

	context "when initializing" do

		it "should succeed when given only max_health" do
			healthComp = HealthComponent.new(10)
			expect(healthComp.cur_health).to eq(10)
			expect(healthComp.max_health).to eq(10)
		end

		it "should succeed when given max_health and cur_health" do
			healthComp = HealthComponent.new(20, 10)
			expect(healthComp.cur_health).to eq(10)
			expect(healthComp.max_health).to eq(20)
		end

		it "should ensure max_health > 0 and cur_health > 0" do
			healthComp = HealthComponent.new(-10, -10)
			expect(healthComp.cur_health).to eq(0)
			expect(healthComp.max_health).to eq(0)
		end
	
		it "should ensure cur_health <= max_health" do
			healthComp = HealthComponent.new(10, 20)
			expect(healthComp.cur_health).to eq(10)
			expect(healthComp.max_health).to eq(10)
		end
	end

	context "when setting cur_health" do

		it "should set cur_health to the given health" do
			basicHealth.cur_health = 5
			expect(basicHealth.cur_health).to eq(5)			
			basicHealth.cur_health = 0
			expect(basicHealth.cur_health).to eq(0)
		end


		it "should ensure 0 <= cur_health" do
			basicHealth.cur_health = -20
			expect(basicHealth.cur_health).to eq(0)
		end
		
		it "should ensure cur_health <= max_health" do
			basicHealth.cur_health = 15
			expect(basicHealth.cur_health).to eq(10)
		end
	end
	
	context "when setting max_health" do
	
		it "should increase max_health and cur_health appropriately" do
			basicHealth.max_health = 20
			expect(basicHealth.cur_health).to eq(20)
			expect(basicHealth.max_health).to eq(20)
		end

		it "should ensure 0 <= max_health and 0 <= cur_health" do
			basicHealth.max_health = -10
			expect(basicHealth.cur_health).to eq(0)
			expect(basicHealth.max_health).to eq(0)
		end

		context "and max_health increases" do
		
			it "should maintain the diff between max_health and cur_health" do
				healthComp = HealthComponent.new(10, 5)
				healthComp.max_health = 15
				expect(healthComp.cur_health).to eq(10)
				expect(healthComp.max_health).to eq(15)
			end
		end

		context "and max_health decreases" do
		
			it "should keep cur_health the same" do
				healthComp = HealthComponent.new(10, 5)
				healthComp.max_health = 7
				expect(healthComp.cur_health).to eq(5)
				expect(healthComp.max_health).to eq(7)
			end
		end
	end

	it "should be alive" do
		expect(basicHealth.alive?).to be true
	end

	it "should be dead" do
		basicHealth.cur_health = 0
		expect(basicHealth.alive?).to be false
	end

	it "should have implemented to_s" do
		expect(basicHealth).to respond_to :to_s
		
		expect(basicHealth.to_s.class).to eq(String)
	end
end
