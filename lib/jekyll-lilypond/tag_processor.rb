module Jekyll
  module Lilypond
    class TagProcessor
      attr_accessor :site

      def initialize(site, tag)
        @site = site
        @tag = tag
      end

      def source
        fetch_template(:source).render(@tag.attrs)
      end

      def filename
        Digest::MD5.hexdigest(source)
      end

      def include
        fetch_template(:include).render(@tag.attrs.update("filename" => filename))
      end

      def run! 
        fp = FileProcessor.new("#{site.source}/lilypond_files", source)
        fp.write
        fp.compile
      end

      def fetch_template(type)
        name = template_name(type)
        content = template_content(name)
        Liquid::Template.parse(content)
      end

      def template_name(type)
        if type == :source
          @tag.source_template_name 
        elsif type == :include
          @tag.include_template_name
        end
      end

      def template_content(template_name)
        site.layouts[template_name].content.strip
      end
    end
  end
end

