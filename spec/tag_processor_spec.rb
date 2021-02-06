require "jekyll-lilypond"
require "spec_helper"
require "tmpdir"
include Liquid

RSpec.describe(Jekyll::Lilypond::TagProcessor) do
  let(:overrides) { {} }
  let(:config) do
    Jekyll.configuration(Jekyll::Utils.deep_merge_hashes({
      "full_rebuild" => true,
      "source"       => source_dir,
      "destination"  => dest_dir,
      "show_drafts"  => false,
      "url"          => "http://example.org",
      "name"         => "My awesome site",
      "author"       => {
        "name" => "Dr. Jekyll",
      },
      "collections"  => {
        "my_collection" => { "output" => true },
        "other_things"  => { "output" => false },
      },
    }, overrides))
  end
  let(:site)     { Jekyll::Site.new(config) }
  let(:context)  { make_context(:site => site) }
  before(:each) do
    FileUtils.rm_r Dir.glob(dest_dir("*"))
    FileUtils.rm_r Dir.glob(source_dir("lilypond_files/*"))
    site.process
  end


  context "initialization" do
    let(:tag) { double("Tag") }
    it "gets the site object" do
      tp = described_class.new(site, tag)
      name = tp.send(:site).source
      expect(name).to eq(SOURCE_DIR)
    end
  end

  context "fetching templates" do
    let(:tag) { double("Tag") }
    let(:tp) { described_class.new(site, tag) }
    let(:template_file) { "vacuous_ly" }
    let(:template_file_contents) { "{{- content -}}" }

    it "can access the tag's source_template_name property" do
      expect(tag).to receive(:source_template_name).and_return("foo")
      expect(tp.template_name(:source)).to eq("foo")
    end
    it "can access the tag's include_template_name property" do
      expect(tag).to receive(:include_template_name).and_return("foo")
      expect(tp.template_name(:include)).to eq("foo")
    end
    it "can look up the content for a template name" do
      expect(tp.template_content(template_file)).to eq(template_file_contents)
    end
    it "fetching a source template returns a Liquid::Template with its contents" do
      allow(tp).to receive(:template_name).and_return(template_file)
      expect(Liquid::Template).to receive("parse").with(template_file_contents)
      tp.fetch_template(:source)
    end
    it "fetching an include template returns a Liquid::Template with its contents" do
      allow(tp).to receive(:template_name).and_return(template_file)
      expect(Liquid::Template).to receive("parse").with(template_file_contents)
      tp.fetch_template(:include)
    end
  end

  context "generating code" do
    let(:tag) { double("Tag", attrs: {"a" => "1", "b" => "2", "content" => "text"}) }
    let(:template) { Liquid::Template.parse("{{a}} {{b}} {{content}}") }
    let(:rendered_text) { "1 2 text" }
    let(:tp) { described_class.new(site, tag) }

    it "renders the source template using tag variables" do
      allow(tp).to receive(:fetch_template).with(:source).and_return(template)
      expect(tp.source).to eq(rendered_text)
    end
    it "renders the include template using tag variables" do
      allow(tp).to receive(:fetch_template).with(:include).and_return(template)
      allow(tp).to receive(:fetch_template).with(:source).and_return(template)
      expect(tp.include).to eq(rendered_text)
    end
  end

  context "generating filename" do
    let(:tag) { double("Tag", attrs: {"a" => "1", "b" => "2", "content" => "text"}) }
    let(:source) { "abcde" }
    let(:hash) { "ab56b4d92b40713acc5af89985d4b786" }
    let(:template) { Liquid::Template.parse("{{filename}} {{content}}") }
    let(:rendered_text) { "#{hash} text" }
    let(:tp) { described_class.new(site, tag) }

    it "generates a filename as the hash of the source" do
      allow(tp).to receive(:source).and_return(source)
      expect(tp.filename).to eq(hash)
    end
    it "provides the filename to the include template" do
      allow(tp).to receive(:source).and_return(source)
      allow(tp).to receive(:fetch_template).with(:include).and_return(template)
      expect(tp.include).to eq(rendered_text)
    end
  end

  context "compiling" do
    let(:tag) { double("Tag", attrs: {"a" => "1", "b" => "2", "content" => "text"}) }
    let(:tp) { described_class.new(site, tag) }
    let(:fp) { double("FileProcessor", write: true, compile: true) }

    it "creates and runs a file processor object" do
      allow(tp).to receive(:source).and_return("")
      expect(Jekyll::Lilypond::FileProcessor).to receive(:new).and_return(fp)
      expect(fp).to receive(:write)
      expect(fp).to receive(:compile)
      tp.run!
    end
  end

  context "integration tests" do
    let(:tag) { Jekyll::Lilypond::Tag.new({"a" => "1", 
                                           "b" => "2", 
                                           "source_template" => "vacuous_ly", 
                                           "include_template" => "variables_html"}, 
                                      "{ a b c d e }") }
    let(:tp) { described_class.new(site, tag) }
    let(:target) { source_dir("lilypond_files/#{tp.filename}.png") }
    it "can render a real tag object" do
      expect(tp.source).to eq("{ a b c d e }")
    end
    it "uses variables from a real tag object" do
      expect(tp.include).to eq("1 { a b c d e } 2")
    end
    it "produces a PNG at the expected location in the site source tree" do
      tp.run!
      expect(File).to exist(target)
    end
  end
end
