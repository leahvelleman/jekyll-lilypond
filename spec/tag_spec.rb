require "jekyll-lilypond"
require "spec_helper"
include Liquid

RSpec.describe(Jekyll::Lilypond::Tag) do
  context "initialization" do
    it "stores attribute values" do
      t = described_class.new({"foo" => "bar"}, "text")
      expect(t.attrs["foo"]).to eq("bar")
    end
    it "stores content" do
      t = described_class.new({"foo" => "bar"}, "text")
      expect(t.attrs["content"]).to eq("text")
    end
    it "stores source template addresses separately" do
      t = described_class.new({"foo" => "bar", "source_template" => "filename.ly"}, "text")
      expect(t.attrs["source_template"]).to eq(nil)
    end
    it "stores source template addresses in template_names" do
      t = described_class.new({"foo" => "bar", "source_template" => "filename.ly"}, "text")
      expect(t.template_names[:source]).to eq("filename.ly")
    end
    it "stores source template code in template_code" do
      t = described_class.new({"foo" => "bar", "source_template_code" => "foo"}, "text")
      expect(t.template_code[:source]).to eq("foo")
    end
    it "stores include template addresses separately" do
      t = described_class.new({"foo" => "bar", "include_template" => "filename.ly"}, "text")
      expect(t.attrs["include_template"]).to eq(nil)
    end
    it "stores include template addresses in template_names" do
      t = described_class.new({"foo" => "bar", "include_template" => "filename.ly"}, "text")
      expect(t.template_names[:include]).to eq("filename.ly")
    end
    it "stores include template code in template_code" do
      t = described_class.new({"foo" => "bar", "include_template_code" => "foo"}, "text")
      expect(t.template_code[:include]).to eq("foo")
    end
    it "copes with missing text" do
      expect { described_class.new({"foo" => "bar"}, "") }.to_not raise_error()
    end
    it "creates template_names and template_code even when no values are provided" do
      t = described_class.new({"foo" => "bar"}, "")
      expect(t.template_names).to eq({source: nil, include: nil})
      expect(t.template_code).to eq({source: nil, include: nil})
    end
    it "copes with empty attrs" do
      expect { described_class.new({}, "text") }.to_not raise_error()
    end
  end
end
