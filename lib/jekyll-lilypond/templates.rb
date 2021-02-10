module Jekyll
  module Lilypond
    class Template
      def initialize(site, template_code:nil, template_name:nil)
        @site = site
        @template_code = template_code
        @template_name = template_name
        @liquid_template_obj = Liquid::Template.parse(template_code)
      end

      def foo
        @liquid_template_obj
      end

      def render(tag)
        @liquid_template_obj.render(tag.attrs)
      end

      def template_code
        @template_code || template_by_name
      end

      private
      def template_by_name
        @site.layouts[@template_name] or raise LoadError.new(
          "No template named #{@template_name} in _layouts/")
      end
    end
  end
end

