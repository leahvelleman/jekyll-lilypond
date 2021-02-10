require "jekyll-lilypond"
require "spec_helper"
include Liquid

long_content =<<-CONTENT 
thing thing thing
stuff stuff stuff
(╯°□°）╯︵ ┻━┻)
❤️ 💔 💌 💕 💞 💓 💗 💖 💘 💝 💟 💜 💛 💚 💙
stuff stuff stuff
thing 
CONTENT

RSpec.describe(Jekyll::Lilypond::Template) do
  let(:site) { double("Site", layouts: { "template1" => "{{ content }}a",
                                         "template2" => "{{ content }}b" }) }

  let(:tag) {double("Tag", attrs: {"content" => "text", 
                                   "a" => "1", 
                                   "b" => "2"})
  }
  let(:long_tag) {double("Tag", attrs: {"content" => long_content, 
                                        "a" => "1", 
                                        "b" => "2"})
  }

  let(:no_variable_template) { "{{ content }}" }
  let(:variable_template) { "{{ content }}{{ a }}{{ b }}" }

  context "literal template code" do
    it "creates a Liquid template" do 
      expect(Liquid::Template).to receive(:parse).with(no_variable_template)
      described_class.new(site, template_code:no_variable_template)
    end

    context "with no variables" do 
      subject { described_class.new(site, template_code:no_variable_template) }
      it "accesses the content attribute" do
        expect(subject.render(tag)).to eq("text")
      end
      it "handles multiline content" do
        expect(subject.render(long_tag)).to eq(long_content)
      end
    end

    context "with variables" do 
      subject { described_class.new(site, template_code:variable_template) }
      it "accesses the content attribute" do
        expect(subject.render(tag)).to eq("text12")
      end
      it "handles missing variables" do
        expect(subject.render(double("Tag", attrs: {"content" => "foo"}))).to eq("foo")
      end
      it "handles multiline content" do
        expect(subject.render(long_tag)).to eq("#{long_content}12")
      end
    end

    context "html-like template" do
      let(:html_ready_tag) { double("Tag",
                                       attrs: {"filename" => "r3y90rqyq3894yrw84rwq43",
                                               "class" => "foo"}) }
      let(:html_template) { "<img src='{{ filename }}.png' class='score {{ class }}' />" }
      let(:output) {"<img src='r3y90rqyq3894yrw84rwq43.png' class='score foo' />"}
      subject { described_class.new(site, template_code:html_template) }
      it "renders correctly" do
        expect(subject.render(html_ready_tag)).to eq(output)
      end
    end
  end

  context "template specified by name" do
    let(:site) { double("Site", layouts: { "template1" => "{{ content }}a",
                                           "template2" => "{{ content }}b" }) }

    it "loads the template" do
      t = described_class.new(site, template_name:"template1")
      expect(t.template_code).to eq("{{ content }}a")
    end
    it "errors when no template by that name exists" do
      t = described_class.new(site, template_name:"fooblesnarf")
      expect { t.template_code }.to raise_error(LoadError)
    end
  end
end

