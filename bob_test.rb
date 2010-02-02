# get_line and get_lines unabashedly stolen from the command_history.rb file in the Utility Belt gem.
module BobTest
  def self.included(base)
    base.send :extend, ClassMethods
  end
  module ClassMethods
    require 'ftools'
    class << self; attr_accessor :test; end
    
    def start_test(name = Time.now.to_s)
      @test = Test.new
      @test.name = name
      @test.start_line = Readline::HISTORY.size - 1
#      "Test starting #{@test.start_line}"
    end
    # todo figure out why there's an off by 1 error.  Would expect size - 1 to be the last command.  
    def end_test
      @test.end_line = Readline::HISTORY.size - 3
      @test.get_lines(@test.start_line..@test.end_line)
      path_to_file = File.expand_path(File.dirname(__FILE__)) + "/../bob/test/unit/"
      File.makedirs(path_to_file)
      filename ="#{self.class_name.underscore}_bob_test.rb"
      filename_with_path =  path_to_file + filename
#      puts "filename wiht path #{filename_with_path}"
#      puts "File exists? #{File.exists?(filename_with_path)}"
      unless File.exists?(filename_with_path)
        f = File.open(filename_with_path, 'w+')
        f.write("class #{self.class_name}BobTest < Bt\nend\n")
        f.close
      end
      @test.write_to_file(filename_with_path)
    end
  end
  
  
  # need to figure out what File.open('/path/to/file', 'wb' ) does # the wb part.
  # commands.rb in rails source
  
  class Test
    attr_accessor :name, :start_line, :end_line, :contents
      # def get_line(line_number)
      #   Readline::HISTORY[line_number] rescue ""
      # end
      def get_lines(lines = [])
        out = []
        lines = lines.to_a if lines.is_a? Range
        lines.each do |l|
          out << Readline::HISTORY[l]
        end
        @contents = out
      end
      
      def write_to_file(file)
        f = File.open(file, 'r+')
        lines = f.readlines
        puts lines.inspect
        puts lines.size
        e = lines.pop         
        until e.eql?("end\n")
          e = lines.pop
          break if lines.empty?
        end
        f.pos = 0
        f.write lines
        f.write "def #{name.gsub(/\W/,'_')}\n"
        f.write @contents.join("\n")
        f.write "\nend\n"
        f.write e
        f.truncate f.pos
        f.close
        # gonna have to run a file indenter !
        # gotta figure out how to load the files this produces
        # pluginify this 
      end

  end
  
end