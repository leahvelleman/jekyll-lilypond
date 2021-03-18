require "digest"

module Jekyll
  module Lilypond
    class FileProcessor
      def initialize(working_dir, hash, source)
        @hash = hash
        @source = source
        @working_dir = working_dir
      end

      def filepath
        "#{@working_dir}/#{@hash}"
      end
        
      def write
        unless File.directory?(@working_dir)
          FileUtils.mkdir_p(@working_dir)
        end
        unless File.exist?("#{filepath}.ly")
          File.open("#{filepath}.ly", "w") do |f|
            f.write(@source)
          end
        end
      end

      def compile
        unless File.exist?("#{filepath}.png")
          Kernel.system("lilypond", "-lERROR", "-dbackend=svg", "--output=#{filepath}", "#{filepath}.ly")
          Kernel.system("convert", "-strip", "-trim", "-density", "404", "-resize", "25%", "#{filepath}.svg",  "#{filepath}.png")
        end
      end
    end
  end
end

