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

  context "rendering" do
    it "loads a lilypond template" do
      tag = make_lilypond_tag_object(optiontext = "ly_template: test")
      tag.render(context)
      expect(tag.ly_template).to eq(site.layouts["test"].content)
    end
    it "errors if a bad template filename is given" do
      tag = make_lilypond_tag_object(optiontext = "ly_template: snarfleblorf")
      expect { tag.render(context) }.to raise_error(LoadError)
    end
    it "loads a default lilypond template if none is specified" do
      tag = make_lilypond_tag_object
      tag.render(context)
      expect(tag.ly_template).to eq("{{ content }}")
    end
    it "accepts a raw template if given one" do
      tag = make_lilypond_tag_object(optiontext = "ly_template_text: 'a {{ content }} b'")
      tag.render(context)
      expect(tag.ly_template).to eq("a {{ content }} b")
    end
    it "renders the template" do
      tag = make_lilypond_tag_object(optiontext = "ly_template_text: 'a {{ content }} b'",
                                     content = "c")
      tag.render(context)
      expect(tag.ly_source).to eq("a c b")
    end
    it "uses attributes when rendering" do
      tag = make_lilypond_tag_object(optiontext = "ly_template_text: '{{ a }} {{ b }}' a:1 b:2")
      tag.render(context)
      expect(tag.ly_source).to eq("1 2")
    end
  end
end

