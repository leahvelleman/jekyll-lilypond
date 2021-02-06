module Jekyll
  module Lilypond
    class Tag
      attr_accessor :attrs, :source_template_name, :include_template_name

      def initialize(attrs, content)
        @attrs = attrs
        @attrs ["content"] = content
        @source_template_name = @attrs.delete("source_template")
        @include_template_name = @attrs.delete("include_template")
      end
    end
  end
end

