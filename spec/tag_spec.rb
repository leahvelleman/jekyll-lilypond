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
    it "stores source template addresses in source_details" do
      t = described_class.new({"foo" => "bar", "source_template" => "filename.ly"}, "text")
      expect(t.source_details[:template_name]).to eq("filename.ly")
    end
    it "stores source template code in source_details" do
      t = described_class.new({"foo" => "bar", "source_template_code" => "foo"}, "text")
      expect(t.source_details[:template_code]).to eq("foo")
    end
    it "stores include template addresses separately" do
      t = described_class.new({"foo" => "bar", "include_template" => "filename.ly"}, "text")
      expect(t.attrs["include_template"]).to eq(nil)
    end
    it "stores include template addresses in source_details" do
      t = described_class.new({"foo" => "bar", "include_template" => "filename.ly"}, "text")
      expect(t.include_details[:template_name]).to eq("filename.ly")
    end
    it "stores include template code in include_details" do
      t = described_class.new({"foo" => "bar", "include_template_code" => "foo"}, "text")
      expect(t.include_details[:template_code]).to eq("foo")
    end
    it "copes with missing text" do
      expect { described_class.new({"foo" => "bar"}, "") }.to_not raise_error()
    end
    it "copes with empty attrs" do
      expect { described_class.new({}, "text") }.to_not raise_error()
    end
  end
end
