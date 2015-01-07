module Bixcalc
  class App
    def add(numbers)
      puts numbers.inject(:+) 
    end
    
    def subtract(numbers)
      numbers.inject(:-) 
    end
    
    def times(numbers)
      numbers.inject(:*) 
    end

    def divide(numbers)
      numbers.inject(:/) 
    end

    def calculate(equation)
     eval(equation)
    end

    def format_numbers(numbers)
      numbers = numbers.split(" ") if !!(numbers =~ / /)
      numbers = numbers.split(",") if !!(numbers =~ /\,/)
      numbers.collect{|i| i.to_i}
    end
  end
end
