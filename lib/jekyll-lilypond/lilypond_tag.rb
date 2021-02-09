module Jekyll
  module Lilypond
    class LilypondTag < Liquid::Block
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
        content = super.strip
        site =  context.registers[:site]

        tag = Tag.new(@attributes, content)
        tp = TagProcessor.new(site, tag)
        tp.run!
        site.static_files << StaticFile.new(site, 
                                            site.source, 
                                            "lilypond_files", 
                                            "#{tp.hash}.png") 

        tp.include
      end
    end
  end
end

Liquid::Template.register_tag("lilypond", Jekyll::Lilypond::LilypondTag)

