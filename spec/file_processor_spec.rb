require "jekyll-lilypond"
require "spec_helper"
require "tmpdir"
include Liquid

RSpec.shared_context 'temp_dir' do
  around do |example|
    Dir.mktmpdir do |dir|
      @temp_dir = dir
      example.run
    end
  end

  attr_reader :temp_dir

  let(:source) { '\version "2.14.1" { c d e f g a b c }' }
  let(:hash) { "99cef9f0865c2c21ba7b5b00d1092f61" }
  let(:filepath) { "#{@temp_dir}/99cef9f0865c2c21ba7b5b00d1092f61.ly" }
end

RSpec.describe(Jekyll::Lilypond::FileProcessor) do
  include_context 'temp_dir'

  context "initialization" do
    it "works if the working dir exists" do
      expect { described_class.new(@temp_dir, @source) }.not_to raise_error
    end
    it "works even if the working dir is in a deeply nested path" do
      path = "#{@temp_dir}/foo/bar/baz/whatever"
      FileUtils.mkdir_p(path)
      expect { described_class.new(path, @source) }.not_to raise_error
    end
    it "errors if the working dir provided doesn't exist" do
      expect { described_class.new(@temp_dir+"asdfasdf", @source) }.to raise_error(IOError)
    end
  end

  context "filename" do
    it "is equal to the hash of the source" do
      file_processor = described_class.new(@temp_dir, source)
      expect(file_processor.filename).to eq(hash)
    end
    it "is defined even when the source is empty" do
      file_processor = described_class.new(@temp_dir, "")
      expect(file_processor.filename)
    end
  end

  context "writing" do
    it "creates a file at the expected location" do
      file_processor = described_class.new(@temp_dir, source)
      file_processor.write
      expect(File.file?(filepath)).to eq(true)
    end
    it "populates that file with the right source" do
      file_processor = described_class.new(@temp_dir, source)
      file_processor.write
      expect(File.open(filepath).read).to eq(source)
    end
  end

  context "compiling" do
    it "calls lilypond" do
      expect(Kernel).to receive(:system).with("lilypond", "--png", filepath)
      file_processor = described_class.new(@temp_dir, source)
      file_processor.write
      file_processor.compile
    end
  end

  context "expectations from lilypond" do
    it "puts output in the target directory even if it's deeply nested" do
      file_processor = described_class.new(@temp_dir, source)
      file_processor.write
      file_processor.compile
      expect(File.exist?("#{@temp_dir}/#{hash}.png")).to eq(true)
    end
  end
  #To do: Error handling
  #To do: Flexible lilypond invocation
  #To do: Do lilypond's products end up in the right place?
end

