module Jekyll
  module Lilypond
    class LilypondTag < Liquid::Block
      def initialize(_, args, _)
        super
      end

      def render(context)
        @contents = super
        @contents
      end
    end
  end
end

Liquid::Template.register_tag("lilypond", Jekyll::Lilypond::LilypondTag)
