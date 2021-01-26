require "jekyll-lilypond"
require "spec_helper"
include Liquid

RSpec.describe(Jekyll::Lilypond::LilypondTag) do
  let(:site) { make_site }
  let(:context) { make_context(:site => site) }
  let(:optiontext) {""}
  let(:content) {""}
  subject { make_lilypond_tag_object(optiontext,content) }


  context "initialization" do
    let (:optiontext) { "a: b c: 'd e' f: \"g h\"" }
    it "stores attribute values" do
      expect(subject.attributes["a"]).to eq("b")
    end
    it "strips quotes from attribute values" do
      expect(subject.attributes["c"]).to eq("d e")
      expect(subject.attributes["f"]).to eq("g h")
    end
  end

  context "unsuccessful template rendering" do
    it "errors if it gets a .html extension when expecting .ly" do
      tag = make_lilypond_tag_object(optiontext = "ly_template: vacuous_html")
      expect { tag.render(context) }.to raise_error(LoadError)
    end
    it "errors if it gets a .ly extension when expecting .html" do
      tag = make_lilypond_tag_object(optiontext = "html_template: vacuous_ly")
      expect { tag.render(context) }.to raise_error(LoadError)
    end
  end

  context "successful template rendering" do
    before { site.process }
    before( :each ){ subject.render(context) }
    context "when used with no arguments" do
      let( :content ){ "foo" }
      it 'loads a default lilypond template' do
        expect(subject.ly_template).to eq(Jekyll::Lilypond::LilypondTag::DEFAULT_LY_TEMPLATE)
      end
      it 'loads a default html template' do
        expect(subject.html_template).to eq(Jekyll::Lilypond::LilypondTag::DEFAULT_MD_TEMPLATE)
      end
    end
    context "when given a specified template" do
      let( :optiontext ){ "ly_template: vacuous_ly" }
      let( :content ){ "foo" }
      it 'loads a template' do
        expect(subject.ly_template).to eq(site.layouts["vacuous_ly"].content)
      end
      it 'populates it with content' do
        expect(subject.ly_source).to eq("foo")
      end
    end
    context "when given a verbal template and variables" do
      let( :optiontext ){ 
        "ly_template_text: '{{ a }} {{ content }} {{ c }}'"\
        "html_template_text: '{{ a }} {{ c }}' a:1 c:3" 
      }
      let( :content ){ "2" }
      it 'accepts the lilypond template' do 
        expect(subject.ly_template).to eq("{{ a }} {{ content }} {{ c }}")
      end
      it 'accepts the html template' do
        expect(subject.html_template).to eq("{{ a }} {{ c }}")
      end
      it 'populates the lilypond template' do expect(subject.ly_source).to eq("1 2 3") end
      it 'populates the html template'     do expect(subject.html_source).to eq("1 3") end
    end
    context "when given a template with liquid filters" do
      let( :optiontext ){ 
        "ly_template_text: '{{ a }} {{ content }} {{ c | plus:3 }}' a:1 c:3" 
      }
      let( :content ){ "2" }
      it 'runs them' do expect(subject.ly_source).to eq("1 2 6") end
    end
  end
end

