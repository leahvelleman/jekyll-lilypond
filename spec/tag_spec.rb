require "jekyll-lilypond"
require "spec_helper"
include Liquid

RSpec.describe(Jekyll::Lilypond::LilypondTag) do
  let(:site) { make_site }
  let(:context) { make_context(:site => site) }

  before { site.process }

  context "initialization" do
    it "stores attribute values" do
      tag = make_lilypond_tag_object(optiontext = "a: b c: d")
      expect(tag.attributes["a"]).to eq("b")
      expect(tag.attributes["c"]).to eq("d")
    end
    it "strips quotes from attribute values" do
      tag = make_lilypond_tag_object(
        optiontext = "a: 'b c' d: \"e f\"")
      expect(tag.attributes["a"]).to eq("b c")
      expect(tag.attributes["d"]).to eq("e f")
    end
  end
end

