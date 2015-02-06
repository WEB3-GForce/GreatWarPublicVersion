require_relative "Component.rb"

class ListComponent < Component
  
  attr_reader :list
  
  def initialize()
    @list = Array.new
  end
  
  def to_s
    "List: " + @list.inspect
  end
  
end

=begin
l = ListComponent.new
l.list.push("3")
l.list.push(2)
l.list.push(nil)
puts l
=end