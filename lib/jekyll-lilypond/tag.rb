module Jekyll
  module Lilypond
    class Tag
      attr_accessor :attrs, :template_names, :template_code

      def initialize(attrs, content)
        @attrs = attrs
        @attrs["content"] = content
        @template_names = { source: @attrs.delete("source_template"),
                            include: @attrs.delete("include_template") }
        @template_code = { source: @attrs.delete("source_template_code"),
                           include: @attrs.delete("include_template_code") }
      end
    end
  end
end

