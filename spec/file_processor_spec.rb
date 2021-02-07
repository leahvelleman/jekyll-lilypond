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
  let(:sourcepath) { "#{@temp_dir}/99cef9f0865c2c21ba7b5b00d1092f61.ly" }
  let(:pngpath) { "#{@temp_dir}/99cef9f0865c2c21ba7b5b00d1092f61.png" }
  let(:barepath) { "#{@temp_dir}/99cef9f0865c2c21ba7b5b00d1092f61" }
end

RSpec.describe(Jekyll::Lilypond::FileProcessor) do
  include_context 'temp_dir'

  context "initialization" do
    it "works if the working dir exists" do
      expect { described_class.new(@temp_dir, hash, source) }.not_to raise_error
    end
    it "works even if the working dir is in a deeply nested path" do
      path = "#{@temp_dir}/foo/bar/baz/whatever"
      FileUtils.mkdir_p(path)
      expect { described_class.new(path, hash, source) }.not_to raise_error
    end
    it "errors if the working dir provided doesn't exist" do
      expect { described_class.new(@temp_dir+"asdfasdf", hash, source) }.to raise_error(IOError)
    end
  end

  context "writing" do
    it "creates a file at the expected location" do
      file_processor = described_class.new(@temp_dir, hash, source)
      file_processor.write
      expect(File.file?(sourcepath)).to eq(true)
    end
    it "populates that file with the right source" do
      file_processor = described_class.new(@temp_dir, hash, source)
      file_processor.write
      expect(File.open(sourcepath).read).to eq(source)
    end
    it "doesn't overwrite an existing source file with the same name" do
      File.open(sourcepath, "w") do |f|
        f.write("This should not be overwritten")
      end
      file_processor = described_class.new(@temp_dir, hash, source)
      file_processor.write
      expect(File.open(sourcepath).read).to eq("This should not be overwritten")
    end
  end

  context "compiling" do
    it "calls lilypond" do
      expect(Kernel).to receive(:system).with("lilypond", "--png", "--output=#{barepath}", 
                                              sourcepath)
      file_processor = described_class.new(@temp_dir, hash, source)
      file_processor.write
      file_processor.compile
    end
    it "doesn't call lilypond if the target png exists" do
      File.open(pngpath, "w") do |f|
        f.write("This should not be overwritten")
      end
      file_processor = described_class.new(@temp_dir, hash, source)
      file_processor.write
      file_processor.compile
      expect(File.open(pngpath).read).to eq("This should not be overwritten")
    end
  end

  context "integration with lilypond" do
    it "puts output in the target directory even if it's deeply nested" do
      path = "#{@temp_dir}/foo/bar/baz/whatever"
      FileUtils.mkdir_p(path)
      file_processor = described_class.new(path, hash, source)
      file_processor.write
      file_processor.compile
      expect(File.exist?("#{path}/#{hash}.png")).to eq(true)
    end
  end
  #To do: Error handling
  #To do: Flexible lilypond invocation
  #To do: Do lilypond's products end up in the right place?
end

