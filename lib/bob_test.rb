# get_line and get_lines unabashedly stolen from the command_history.rb file in the Utility Belt gem.
module BobTest
  def self.included(base)
    base.send :extend, ClassMethods
  end
  module ClassMethods
    require 'ftools'
    class << self; attr_accessor :test; end
    
    def start_test(name = Time.now.to_s)
      @test = BobTest.new
      @test.name = name
      @test.start_line = Readline::HISTORY.size - 1
    end
    
    # todo figure out why there's an off by 1 error.  Would expect size - 1 to be the last command.  
    def end_test
      @test.end_line = Readline::HISTORY.size - 3
      @test.get_lines(@test.start_line..@test.end_line)
      path_to_file = File.expand_path(File.dirname(__FILE__)) + "/../bob/test/unit/"
      File.makedirs(path_to_file)
      filename ="#{self.class_name.underscore}_bob_test.rb"
      filename_with_path =  path_to_file + filename
      File.open(filename_with_path, 'w+') do |f|
        f.write("class #{self.class_name}BobTest < Bt\nend\n")
      end unless File.exists?(filename_with_path)
      @test.write_to_file(filename_with_path)
    end
  end
  
  
  # need to figure out what File.open('/path/to/file', 'wb' ) does # the wb part. (w means write, b means binary)
  # commands.rb in rails source
  
  class BobTest
    
    attr_accessor :name, :start_line, :end_line, :contents, :indentable_words
    
    @indentable_words = %w{begin break case def do else elsif end ensure if in next redo rescue retry return
      super then unless until when while yield}

      def get_lines(lines = [])
        out = []
        lines = lines.to_a if lines.is_a? Range
        lines.each do |l|
          out << Readline::HISTORY[l]
        end
        @contents = out
      end
      
      def write_to_file(file)
        File.open(file, 'r+') do |f|
          lines = f.readlines
          e = lines.pop         
          until e.eql?("end\n")
            e = lines.pop
            break if lines.empty?
          end
          f.pos = 0
          f.write lines
          f.write "  def #{name.gsub(/\W/,'_')}\n"
          @contents.each do |line|
            f.write "    #{line}\n"
          end
          f.write "  end\n"
          f.write e
          f.truncate f.pos
        end
        # gonna have to run a file indenter !
        # gotta figure out how to load the files this produces
        # pluginify this 
      end

  end
  
end