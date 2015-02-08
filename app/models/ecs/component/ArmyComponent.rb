require_relative "ListComponent.rb"

class ArmyComponent < ListComponent

  def to_s
    "Army: " + @list.inspect
  end
  
end

#test = ArmyComponent.new
#puts test
#test.list.push "I am an army guy >:("
#puts test
