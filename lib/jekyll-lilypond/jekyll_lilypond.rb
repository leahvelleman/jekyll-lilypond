module Jekyll
  module Lilypond
    class LilypondTag < Liquid::Block

      DEFAULT_LY_TEMPLATE = "{{ content }}"
      DEFAULT_MD_TEMPLATE = "![{{ alt }}]({{ filename }}.svg)"

      attr_reader :attributes
      attr_reader :ly_template
      attr_reader :ly_source
      attr_reader :html_template
      attr_reader :html_source

      def initialize(_, argtext, _)
        super
        @attributes = parse_attributes(argtext)
      end

      def parse_attributes(text)
        attributes = {}
        text.scan(Liquid::TagAttributes) do |key, value|
          value=value.delete_prefix('"').delete_prefix("'")
          value=value.delete_suffix('"').delete_suffix("'")
          attributes[key] = value
        end
        attributes
      end

      def render(context)
        content = super
        @attributes["content"] = content
        @layouts = context.registers[:site].layouts
        @ly_template = load_ly_template
        @html_template = load_html_template
        @ly_source = Liquid::Template.parse(@ly_template).render(@attributes)
        @html_source = Liquid::Template.parse(@html_template).render(@attributes)
      end

      private

      def load_ly_template
        load_template("ly_template_text",
                      "ly_template",
                      "ly",
                      DEFAULT_LY_TEMPLATE)
      end

      def load_html_template
        load_template("html_template_text",
                      "html_template",
                      "html",
                      DEFAULT_MD_TEMPLATE)
      end

      def load_template(text_key, template_key, ext, default)
        if @attributes[text_key] then return @attributes[text_key] end
        template = @attributes[template_key]
        if template then 
          begin
            if @layouts[template].ext != ".#{ext}"
              raise LoadError.new("Template #{template} is not a .#{ext} file")
            end
            @layouts[template].content
          rescue NoMethodError
            raise LoadError.new("No template called #{template}")
          end
        else
          default
        end
      end
    end
  end
end

Liquid::Template.register_tag("lilypond", Jekyll::Lilypond::LilypondTag)
