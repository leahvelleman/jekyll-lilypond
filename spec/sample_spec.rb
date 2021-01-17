require "spec_helper"

RSpec.describe(Jekyll::Lilypond::LilypondTag) do
  let(:site) { make_site }
  let(:context) { make_context(:site => site) }

  before { site.process }

  context "the tag class" do
    it "can be instantiated" do
      # CURRENT MYSTERY 1/16/2021
      subject
    end
  end

  context "rendering the tag" do
    let(:output) do
      Liquid::Template.parse("{% lilypond %} a b c d e {%endlilypond%}").render!(context, {}) 
    end

    it "produces output" do
      expect(output)
    end

    it "produces one line of output" do
      expect(output.lines.count).to eq 1
    end
  end

  context "full page rendering" do
    let(:content) { File.read(dest_dir("page.html")) }
    
    it "exists" do
      expect(content)
    end
  end
end

