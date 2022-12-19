module Jekyll
  module Lilypond
    class LilypondTag < Liquid::Block
      @@baseurl = Jekyll.configuration({})['baseurl']

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
        attributes["attr_text"] = text
        attributes
      end

      def render(context)
        content = super.strip
        site =  context.registers[:site]

        tag = Tag.new(@attributes, content)
        tp = TagProcessor.new(site, tag, @@baseurl)
        tp.run!
        tp.include
      end
    end
  end
end

Liquid::Template.register_tag("lilypond", Jekyll::Lilypond::LilypondTag)

