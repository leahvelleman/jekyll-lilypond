require "jekyll-lilypond"
require "spec_helper"
include Liquid

long_content =<<-CONTENT 
thing thing thing
stuff stuff stuff
stuff stuff stuff
thing 
CONTENT

RSpec.describe(Jekyll::Lilypond::Template) do
  let(:tag) {double("Tag", 
                    content: "text", 
                    attrs: {"a" => "1", "b" => "2"})
  }
  let(:long_tag) {double("Tag", 
                         content: long_content,
                         attrs: {"a" => "1", "b" => "2"})
  }

  context "initialization" do
    it "parses the template source" do
      expect(Liquid::Template).to receive(:parse).with("source")
      described_class.new("source")
    end
    context "template with no variables" do
      subject { described_class.new("{{ content }}") }
      it "renders the content" do
        expect(subject.render(tag)).to eq("text")
      end
      it "handles multiline content" do
        expect(subject.render(long_tag)).to eq(long_content)
      end
    end
    context "template with content and variables" do
      subject { described_class.new("{{ content }} {{ a }}") }
      it "renders the content" do
        expect(subject.render(tag)).to eq("text 1")
      end
    end
  end
end

