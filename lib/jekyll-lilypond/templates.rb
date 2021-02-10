module Jekyll
  module Lilypond
    class Template
      def initialize(site, template_code:nil, template_name:nil)
        @site = site
        @template_code = template_code
        @template_name = template_name
        @liquid_template_obj = Liquid::Template.parse(fetch_template_code)
      end

      def render(tag)
        @liquid_template_obj.render(tag.attrs)
      end

      def fetch_template_code
        @template_code || template_by_name
      end

      private
      def template_by_name
        layout = @site.layouts[@template_name] or raise LoadError.new(
          "No template named #{@template_name} in _layouts/")
        layout.content.strip
      end
    end
  end
end

