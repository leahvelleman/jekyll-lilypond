require "jekyll-lilypond"
require "ostruct"
require "digest"

include Liquid

RSpec.describe(Jekyll::Lilypond::Job) do
  context "initialization" do
    it "renders the source template" do
      settings = OpenStruct.new(source_template: "foo {{ content }} baz")
      variables = {}
      content = "bar"
      job = described_class.new(settings, variables, content)
      expect(job.source).to eq("foo bar baz")
    end
    it "renders the markdown template" do
      settings = OpenStruct.new(markdown_template: "foo {{ content }} baz")
      variables = {}
      content = "bar"
      job = described_class.new(settings, variables, content)
      expect(job.markdown).to eq("foo bar baz")
    end
    it "uses variables to render the source template" do
      settings = OpenStruct.new(source_template: "{{ a }} {{ b }} {{ c }}")
      variables = {"a" => "foo", "b" => "bar", "c" => "baz"}
      job = described_class.new(settings, variables, "")
      expect(job.source).to eq("foo bar baz")
    end
    it "generates a filename" do
      settings = OpenStruct.new(source_template: "snarfleblorf")
      job = described_class.new(settings, {}, "")
      expect(job.filename).to eq(Digest::SHA256.hexdigest("snarfleblorf"))
    end
    it "is a no-op if you use the filename in the source template" do
      # Shoudl this be an error instead of a no-op
      settings = OpenStruct.new(source_template: "{{ filename }}")
      job = described_class.new(settings, {}, "")
      expect(job.source).to eq("")
    end
    it "can use the filename in the markdown template" do
      settings = OpenStruct.new(
        source_template: "snarfleblorf",
        markdown_template: "{{ filename }}")
      job = described_class.new(settings, {}, "")
      expect(job.markdown).to eq(Digest::SHA256.hexdigest("snarfleblorf"))
    end
  end
end

