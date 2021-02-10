module Jekyll
  module Lilypond
    class Tag
      attr_accessor :attrs, :source_details, :include_details

      def initialize(attrs, content)
        @attrs = attrs
        @attrs ["content"] = content
        @source_details = { template_name: @attrs.delete("source_template"), 
                            template_code: @attrs.delete("source_template_code") }
        @include_details = { template_name: @attrs.delete("include_template"),
                             template_code: @attrs.delete("include_template_code") }
      end
    end
  end
end

