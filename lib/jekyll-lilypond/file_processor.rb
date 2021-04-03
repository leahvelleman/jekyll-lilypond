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
        unless File.exist?("#{filepath}.svg")
          puts "Compiling Lilypond file #{filepath}.ly."
          Kernel.system("lilypond", "-lERROR", 
                        "-dbackend=svg", 
                        "--output=#{filepath}", 
                        "#{filepath}.ly")
        end
      end

      def trim_svg
        if File.exist?("#{filepath}.svg")
          Kernel.system("inkscape", 
                        "#{filepath}.svg", 
                        "--export-area-drawing", 
                        "--export-type=svg", 
                        "--export-filename=#{filepath}.svg")
        else
          raise RuntimeError.new(
            "Cannot trim SVG: expected SVG file #{filepath}.svg does not exist")
        end
      end

      def make_mp3
        unless File.exist?("#{filepath}.mp3")
          if File.exist?("#{filepath}.midi")
            puts "Generating #{filepath}.mp3."
            Kernel.system("timidity", 
                          "#{filepath}.midi", 
                          "-Ow", 
                          "-o", 
                          "#{filepath}.mp3",
                         [:out, :err] => File::NULL)
          else
            raise RuntimeError.new(
              "Cannot generate mp3: expected MIDI file #{filepath}.midi does not exist.")
          end
        end
      end
    end
  end
end

