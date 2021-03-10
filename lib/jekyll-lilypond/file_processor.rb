require "digest"

module Jekyll
  module Lilypond
    class FileProcessor
      def initialize(working_dir, hash, source)
        @hash = hash
        @source = source
        if Dir.exist? working_dir
          @working_dir = working_dir
        else
          raise IOError.new("Specified working directory #{working_dir} does not exist")
        end
      end

      def filepath
        "#{@working_dir}/#{@hash}"
      end
        
      def write
        unless File.exist?("#{filepath}.ly")
          File.open("#{filepath}.ly", "w") do |f|
            f.write(@source)
          end
        end
      end

      def compile
        unless File.exist?("#{filepath}.png")
          Kernel.system("lilypond", "-lERROR", "--ps", "--output=#{filepath}", "#{filepath}.ly")
          Kernel.system("convert", "-strip", "-trim", "-density", "384", "-resize", "25%", "#{filepath}.ps",  "#{filepath}.png")
        end
      end
    end
  end
end

