module Jekyll
  module Lilypond
    class LilypondTag < Liquid::Block

      attr_reader :attributes

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
        @contents = super
      end
    end
  end
end

Liquid::Template.register_tag("lilypond", Jekyll::Lilypond::LilypondTag)
