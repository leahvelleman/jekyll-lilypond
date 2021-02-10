module Jekyll
  module Lilypond
    class TagProcessor
      attr_accessor :site

      def initialize(site, tag)
        @site = site
        @tag = tag
      end

      def source
        source_template_obj.render(@tag)
      end

      def source_template_obj
        Template.new(@site, **@tag.source_details)
      end

      def hash
        Digest::MD5.hexdigest(source)
      end

      def include
        @tag.attrs.update("filename" => hash)
        include_template_obj.render(@tag)
      end

      def include_template_obj
        Template.new(@site, **@tag.include_details)
      end

      def file_processor
        FileProcessor.new("#{site.source}/lilypond_files", hash, source)
      end

      def run! 
        file_processor.write
        file_processor.compile
      end
    end
  end
end

