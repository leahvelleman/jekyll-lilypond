module Jekyll
  module Lilypond
    class LilypondTag < Liquid::Block
      def render(context)
        "<img>"
      end
    end
  end
end

Liquid::Template.register_tag("lilypond", Jekyll::Lilypond::LilypondTag)

