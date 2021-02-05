module Jekyll
  module Lilypond
    class Template
      def initialize(source)
        @template = Liquid::Template.parse(source)
      end

      def render(tag)
        @template.render(tag.attrs)
      end
    end
  end
end

