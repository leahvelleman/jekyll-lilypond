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
  let(:site) { double("Site", layouts: { "name_a" => layout_a,
                                         "name_b" => layout_b },
                              lilypond: double(default_source_template: "name_a",
                                               default_include_template: "name_c")) } 
  let(:template_a) { "{{ content }}" }
  let(:template_b) { "{{ content }}{{ a }}{{ b }}" }
  let(:template_c) { "{{ content }}{{ a }}{{ b }}{{ c }}{{ d }}" }
  let(:layout_a) { double(content: template_a) }
  let(:layout_b) { double(content: template_b) }
  let(:layout_c) { double(content: template_c) }

  context "when fetching templates" do
    context "literal template code" do
      let(:tag) { double("Tag", 
                         attrs: {},
                         source_details: { template_code: template_a },
                         include_details: { template_code: template_b }) }
      it "is used verbatim for source" do
        subject = described_class.new(site, tag, :source)
        expect(subject.fetch_template_code).to eq(template_a)
      end
      it "is used verbatim for includes" do
        subject = described_class.new(site, tag, :include)
        expect(subject.fetch_template_code).to eq(template_b)
      end
    end
    context "a valid template name" do
      let(:tag) { double("Tag", 
                         attrs: {},
                         source_details: { template_name: "name_a" },
                         include_details: { template_name: "name_b" }) }
      it "loads the corresponding source template" do
        subject = described_class.new(site, tag, :source)
        expect(subject.fetch_template_code).to eq(template_a)
      end
      it "loads the corresponding include template" do
        subject = described_class.new(site, tag, :include)
        expect(subject.fetch_template_code).to eq(template_b)
      end
    end
    context "a template name that the plugin defines but the site doesn't" do
      let(:tag) { double("Tag",
                         attrs: {},
                         source_details: { template_name: "empty" },
                         include_details: { template_name: "empty" }) }
      it "loads the corresponding plugin source template" do
        subject = described_class.new(site, tag, :source)
        expect(subject.fetch_template_code).to eq("{{ content }}")
      end
      it "loads the corresponding plugin include template" do
        subject = described_class.new(site, tag, :include)
        expect(subject.fetch_template_code).to eq("{{ content }}")
      end
    end
    context "a template name that the plugin and the site define" do
      let(:differentsite) { double("Site", layouts: { "empty" => layout_a }) }
      let(:tag) { double("Tag",
                         attrs: {},
                         source_details: { template_name: "empty" },
                         include_details: { template_name: "empty" }) }
      it "gives the site version of the source template precedence" do
        subject = described_class.new(differentsite, tag, :source)
        expect(subject.fetch_template_code).to eq(template_a)
      end
      it "gives the site version of the include template precedence" do
        subject = described_class.new(differentsite, tag, :include)
        expect(subject.fetch_template_code).to eq(template_a)
      end

                         
    end
    context "an invalid template name" do
      let(:tag) { double("Tag",
                         attrs: {},
                         source_details: { template_name: "i_do_not_exist" },
                         include_details: { template_name: "me_neither" }) }
      it "raises an error when it's a source template name" do
        subject = described_class.new(site, tag, :source)
        expect { subject.fetch_template_code }.to raise_exception(LoadError)
      end
      it "raises an error when it's an include template name" do
        subject = described_class.new(site, tag, :include)
        expect { subject.fetch_template_code }.to raise_exception(LoadError)
      end
    end
    context "a totally unspecified template" do
      let(:tag) { double("Tag",
                         attrs: {},
                         source_details: {},
                         include_details: {}) }

      it "gets a site default template" do
        subject = described_class.new(site, tag, :source)
        expect(subject.fetch_template_code).to eq(template_a)
      end
      it "raises an error if the site default points to a nonexistant template" do
        subject = described_class.new(site, tag, :include)
        expect { subject.fetch_template_code }.to raise_error(LoadError)
      end
    end
  end

  context "rendering" do
    let(:tag) { double("Tag", 
                       attrs: {"content" => "text",
                               "a" => "1",
                               "b" => "2"},
                       source_details: { template_code: template_a },
                       include_details: { template_code: template_b }) }
    let(:long_tag) { double("Tag", 
                       attrs: {"content" => long_content,
                               "a" => "1",
                               "b" => "2"},
                       source_details: { template_code: template_a },
                       include_details: { template_code: template_b }) }
    it "renders a template without variables" do
      subject = described_class.new(site, tag, :source)
      expect(subject.render(tag)).to eq("text")
    end
    it "renders a template with variables" do
      subject = described_class.new(site, tag, :include)
      expect(subject.render(tag)).to eq("text12")
    end
    it "handles multiline content" do
      subject = described_class.new(site, long_tag, :include)
      expect(subject.render(long_tag)).to eq("#{long_content}12")
    end
  end
end

