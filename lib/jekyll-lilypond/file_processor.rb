require "digest"

module Jekyll
  module Lilypond
    class FileProcessor
      def initialize(working_dir, source)
        @source = source
        if Dir.exist? working_dir
          @working_dir = working_dir
        else
          raise IOError.new("Specified working directory #{working_dir} does not exist")
        end
      end

      def filename
        Digest::MD5.hexdigest @source
      end

      def filepath
        "#{@working_dir}/#{filename}"
      end
        
      def write
        File.open("#{filepath}.ly", "w") do |f|
          f.write(@source)
        end
      end

      def compile
        Kernel.system("lilypond", "--png", "--output=#{filepath}", "#{filepath}.ly")
      end
    end
  end
end

