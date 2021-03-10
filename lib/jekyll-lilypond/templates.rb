module Jekyll
  module Lilypond
    class Template
      def initialize(site, tag, type)
        @site = site
        @type = type
        if @type == :source
          @template_code = tag.source_details[:template_code]
          @template_name = tag.source_details[:template_name]
        elsif @type == :include
          @template_code = tag.include_details[:template_code]
          @template_name = tag.include_details[:template_name]
        end
      end

      def render(tag)
        Liquid::Template.parse(fetch_template_code).render(tag.attrs)
      end

      def fetch_template_code
        @template_code || template_by_name(@template_name) || template_by_name(default_template)
      end

      private
      def template_by_name(n)
        if n
          layout = @site.layouts[n] or raise LoadError.new(
            "No template named #{n} in _layouts/")
          layout.content.strip
        end
      end

      def default_template
        if @type == :source
          @site.lilypond.default_source_template
        elsif @type == :include
          @site.lilypond.default_include_template
        end
      end
    end
  end
end

