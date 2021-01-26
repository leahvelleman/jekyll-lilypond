require "digest"

module Jekyll
  module Lilypond
    class Job
      attr_reader :source
      attr_reader :filename
      attr_reader :markdown

      def initialize(settings, variables, content)
        variables["content"] = content
        source_template = Liquid::Template.parse(settings.source_template)
        markdown_template = Liquid::Template.parse(settings.markdown_template)
        @source = source_template.render(variables)
        @filename = Digest::SHA256.hexdigest(source)
        variables["filename"] = @filename
        @markdown = markdown_template.render(variables)
      end
    end
  end
end

