require "jekyll-lilypond"
require "spec_helper"
require "tmpdir"
include Liquid

RSpec.describe(Jekyll::Lilypond::TagProcessor) do
  let(:site) { double("source" => "/some/directory") }
  let(:tag) { double("Tag", source_details: { :template_name => "NiftyTemplateName" },
                            include_details: { :template_code => "{{ filename }} abcde" },
                            attrs: {} ) }
  let(:subject) { described_class.new(site, tag) }

  context "generating source code" do
    it "creates a Template using the tag data when you ask for a source template" do
      expect(Jekyll::Lilypond::Template).to receive(:new).with(site, tag, :source)
      subject.source_template_obj
    end
  end

  context "generating include code" do
    it "creates a Template using the tag data when you ask for an include template" do
      expect(Jekyll::Lilypond::Template).to receive(:new).with(site, tag, :include)
      subject.include_template_obj
    end
  end

  context "generating filename" do
    let(:source) { "abcde" }
    let(:hash) { "ab56b4d92b40713acc5af89985d4b786" }

    it "generates a filename as the hash of the source" do
      allow(subject).to receive(:source).and_return(source)
      expect(subject.hash).to eq(hash)
    end
    it "makes the filename available to the include template" do
      allow(subject).to receive(:source).and_return(source)
      expect(subject.include).to eq("#{hash} abcde")
    end
    it "provides the filename to the file processor" do
      allow(subject).to receive(:source).and_return(source)
      expect(Jekyll::Lilypond::FileProcessor).to \
        receive(:new).with("/some/directory/lilypond_files", hash, source)
      subject.file_processor
    end
  end
end

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
    site.process
  end
  after(:each) do
    FileUtils.rm_r Dir.glob(source_dir("lilypond_files/*"))
  end

  context "integration tests" do
    let(:code_tag) { Jekyll::Lilypond::Tag.new({ "source_template_code" => '\version "2.20.0" { {{ content }} }',
                                                 "include_template_code" => '<img src="{{ filename }}.png" />' },
                                               "a b c d e") }
    let(:subject) { described_class.new(site, code_tag) }
    let(:target_hash) { "bfcae429ec31cea750c3ab8167526c7c" }
    let(:target_include) { '<img src="bfcae429ec31cea750c3ab8167526c7c.png" />' }
    let(:target_path) { "#{source_dir}/lilypond_files/bfcae429ec31cea750c3ab8167526c7c.png" }

    it "Generates the correct hash from a real tag with explicit code" do
      expect(subject.hash).to eq(target_hash)
    end
    it "Produces a PNG file at the expected location in the source tree" do
      subject.run!
      expect(File).to exist(target_path)
    end
    it "Includes the filename in the include code" do
      expect(subject.include).to eq(target_include)
    end
  end
end
