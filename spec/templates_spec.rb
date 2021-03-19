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
                              lilypond: double(template_names: 
                                                 { source: "name_a",
                                                   include: "name_b" } )) } 
  let(:site_without_defaults) { double("Site", layouts: { "name_a" => layout_a,
                                                          "name_b" => layout_b }) }
  let(:template_a) { "{{ content }}" }
  let(:template_b) { "{{ content }}{{ a }}{{ b }}" }
  let(:template_c) { "{{ content }}{{ a }}{{ b }}{{ c }}{{ d }}" }
  let(:layout_a) { double(content: template_a) }
  let(:layout_b) { double(content: template_b) }
  let(:layout_c) { double(content: template_c) }

  context "getting template names" do
    context "when they are given by the tag" do
      let(:tag) { double("Tag", attrs: {},
                         template_code: {source: nil, include: nil },
                         template_names: { source: "foo", include: "bar" }) }
      it "returns the given source template name" do
        subject = described_class.new(site, tag, :source)
        expect(subject.template_name).to eq("foo")
      end
      it "returns the given include template name" do
        subject = described_class.new(site, tag, :include)
        expect(subject.template_name).to eq("bar")
      end
    end
    context "when they are not given by the tag" do
      let(:tag) { double("Tag", attrs: {},
                         template_code: {source: nil, include: nil },
                         template_names: { source: nil, include: nil }) }
      it "returns the sitewide source template name" do
        subject = described_class.new(site, tag, :source)
        expect(subject.template_name).to eq("name_a")
      end
      it "returns the sitewide include template name" do
        subject = described_class.new(site, tag, :include)
        expect(subject.template_name).to eq("name_b")
      end
      it "won't error when there is no sitewide template name" do
        subject = described_class.new(site_without_defaults, tag, :source)
        expect { subject.template_name }.not_to raise_exception 
      end
    end
    context "when they are not given by the tag or the site" do
      let(:tag) { double("Tag", attrs: {},
                         template_code: {source: nil, include: nil },
                         template_names: { source: nil, include: nil }) }
      it "returns the pluginwide source template name" do
        subject = described_class.new(site_without_defaults, tag, :source)
        expect(subject.template_name).to eq("basic")
      end
      it "returns the pluginwide include template name" do
        subject = described_class.new(site_without_defaults, tag, :include)
        expect(subject.template_name).to eq("img")
      end
    end
  end

  context "when fetching templates" do
    context "literal template code" do
      let(:tag) { double("Tag", attrs: {},
                         template_names: { source: nil, include: nil },
                         template_code: { source: "foo", include: "bar" }) }
      it "is used verbatim for source" do
        subject = described_class.new(site, tag, :source)
        expect(subject.template_code).to eq("foo")
      end
      it "is used verbatim for includes" do
        subject = described_class.new(site, tag, :include)
        expect(subject.template_code).to eq("bar")
      end
    end
    context "a valid template name" do
      let(:tag) { double("Tag", 
                         attrs: {},
                         template_names: { source: "name_a", include: "name_b" },
                         template_code: { source: nil, include: nil }) }
      it "loads the corresponding source template" do
        subject = described_class.new(site, tag, :source)
        expect(subject.template_code).to eq(template_a)
      end
      it "loads the corresponding include template" do
        subject = described_class.new(site, tag, :include)
        expect(subject.template_code).to eq(template_b)
      end
    end
    context "a template name that the plugin defines but the site doesn't" do
      let(:tag) { double("Tag", 
                         attrs: {},
                         template_names: { source: "raw", include: "raw" },
                         template_code: { source: nil, include: nil }) }
      it "loads the corresponding plugin source template" do
        subject = described_class.new(site, tag, :source)
        expect(subject.template_code).to eq("{{ content }}")
      end
      it "loads the corresponding plugin include template" do
        subject = described_class.new(site, tag, :include)
        expect(subject.template_code).to eq("{{ content }}")
      end
    end
    context "a template name that the plugin and the site both define" do
      let(:differentsite) { double("Site", layouts: { "raw" => layout_a }) }
      let(:tag) { double("Tag",
                         attrs: {},
                         template_names: { source: "raw", include: "raw" },
                         template_code: { source: nil, include: nil }) }
      it "gives the site version of the source template precedence" do
        subject = described_class.new(differentsite, tag, :source)
        expect(subject.template_code).to eq(template_a)
      end
      it "gives the site version of the include template precedence" do
        subject = described_class.new(differentsite, tag, :include)
        expect(subject.template_code).to eq(template_a)
      end
    end
    context "an invalid template name" do
      let(:tag) { double("Tag",
                         attrs: {},
                         template_names: { source: "i_do_not_exist", include: "i_do_not_exist" },
                         template_code: { source: nil, include: nil }) }
      it "raises an error when it's a source template name" do
        subject = described_class.new(site, tag, :source)
        expect { subject.template_code }.to raise_exception(LoadError)
      end
      it "raises an error when it's an include template name" do
        subject = described_class.new(site, tag, :include)
        expect { subject.template_code }.to raise_exception(LoadError)
      end
    end
  end

  context "rendering" do
    let(:tag) { double("Tag", 
                       attrs: {"content" => "text",
                               "a" => "1",
                               "b" => "2"},
                       template_code: { source: template_a, include: template_b },
                       template_names: { source: nil, include: nil }) }
    let(:long_tag) { double("Tag", 
                       attrs: {"content" => long_content,
                               "a" => "1",
                               "b" => "2"},
                       template_code: { source: template_a, include: template_b },
                       template_names: { source: nil, include: nil }) }
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

