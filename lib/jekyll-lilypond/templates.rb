module Jekyll
  module Lilypond
    class Template
      def initialize(source)
        @template = Liquid::Template.parse(source)
      end

      def render(tag)
        args = tag.attrs.merge("content" => tag.content)
        @template.render(args)
      end
    end
  end
end

