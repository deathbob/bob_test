class Bt
  
  def run_tests
    self.class.send(:methods_to_test).all?{|meth| self.send meth.intern}
  end
  
  def sassy
    puts "FUCK OFF"
  end
  
  def self.methods_to_test
    self.new.methods - self.methods - ['run_tests']
  end
    
end