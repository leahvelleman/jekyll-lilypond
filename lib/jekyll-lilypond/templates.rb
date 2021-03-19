module Jekyll
  module Lilypond
    class Template
      def initialize(site, tag, type)
        @site = site
        @type = type
        @tag_template_names = tag.template_names
        @tag_template_code = tag.template_code
      end

      def render(tag)
        Liquid::Template.parse(template_code).render(tag.attrs)
      end

      def template_name
        @tag_template_names[@type] || sitewide_template_names[@type] || plugin_template_names[@type]
      end

      def template_code
        @tag_template_code[@type] or 
          fetch_site_template(template_name) or
          fetch_plugin_template(template_name) or
          raise LoadError.new("No template named #{template_name}.#{extension}")
      end


      private
      def sitewide_template_names
        if @site.respond_to? :lilypond and @site.lilypond.respond_to? :template_names 
          @site.lilypond.template_names
        else
          { source: nil, include: nil }
        end
      end

      def plugin_template_names
        { source: "basic", include: "img" }
      end

      def fetch_site_template(name)
        if @site.layouts[name]
          @site.layouts[name].content.strip
        end
      end

      def fetch_plugin_template(name)
        dir = File.join(File.dirname(__dir__), "/jekyll-lilypond/templates/")
        filename = File.join(dir, "#{name}.#{extension}")
        if File.exists?(filename)
          File.read(filename).strip
        end
      end

      def extension
        if @type == :source then "ly" else "html" end
      end
    end
  end
end

