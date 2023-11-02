# example from https://blog.kiprosh.com/type-checking-in-ruby-3-using-rbs/
# basic_math.rb

class BasicMath
  def initialize(num1, num2)
    @num1 = num1
    @num2 = num2
  end

  def first_less_than_second?
    @num1 < @num2
  end

  def add
    @num1 + @num2
  end
end
