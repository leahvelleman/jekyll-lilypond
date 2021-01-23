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
    ["ly", "html"].each do |filetype|
      it "loads a #{filetype} template" do
        tag = make_lilypond_tag_object(optiontext = "#{filetype}_template: vacuous_#{filetype}")
        tag.render(context)
        expect(tag.send("#{filetype}_template")).to eq(site.layouts["vacuous_#{filetype}"].content)
      end
      it "errors if a bad #{filetype} template filename is given" do
        tag = make_lilypond_tag_object(optiontext = "#{filetype}_template: snarfleblorf")
        expect { tag.render(context) }.to raise_error(LoadError)
      end
      it "errors if it gets a non-lilypond template instead of a lilypond one" do
        tag = make_lilypond_tag_object(optiontext = "ly_template: vacuous_html")
        expect { tag.render(context) }.to raise_error(LoadError)
      end
      it "errors if it gets a non-html template instead of a html one" do
        tag = make_lilypond_tag_object(optiontext = "html_template: vacuous_ly")
        expect { tag.render(context) }.to raise_error(LoadError)
      end
      it "loads a default #{filetype} template if none is specified" do
        tag = make_lilypond_tag_object
        tag.render(context)
        expect(tag.send("#{filetype}_template")).to eq("{{ content }}")
      end
      it "accepts a raw #{filetype} template if given one" do
        tag = make_lilypond_tag_object(optiontext = "#{filetype}_template_text: 'a {{ content }} b'")
        tag.render(context)
        expect(tag.send("#{filetype}_template")).to eq("a {{ content }} b")
      end
      it "renders the #{filetype} template" do
        tag = make_lilypond_tag_object(optiontext = "#{filetype}_template: vacuous_#{filetype}",
                                       content = "c")
        tag.render(context)
        expect(tag.send("#{filetype}_source")).to eq("c")
      end
      it "uses attributes when rendering #{filetype} template" do
        tag = make_lilypond_tag_object(optiontext = "#{filetype}_template: variables_#{filetype} a:1 b:3", content = "2")
        tag.render(context)
        expect(tag.send("#{filetype}_source")).to eq("1 2 3")
      end
    end
  end
end

