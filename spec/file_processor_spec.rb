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
  let(:svgpath) { "#{@temp_dir}/99cef9f0865c2c21ba7b5b00d1092f61.svg" }
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
    it "creates the working directory if it does not exist" do
      path = "#{@temp_dir}/foo/bar/baz/whatever"
      expect { 
        fp = described_class.new(path, hash, source) 
        fp.write
      }.not_to raise_error
      expect(File.exists?(path)).to eq(true)
    end
  end

  context "compiling" do
    it "results in an svg file" do
      file_processor = described_class.new(@temp_dir, hash, source)
      file_processor.write
      file_processor.compile
      expect(File.exist?(svgpath)).to eq(true)
    end
    it "doesn't call lilypond if the target svg exists" do
      File.open(svgpath, "w") do |f|
        f.write("This should not be overwritten")
      end
      file_processor = described_class.new(@temp_dir, hash, source)
      file_processor.write
      file_processor.compile
      expect(File.open(svgpath).read).to eq("This should not be overwritten")
    end
  end
  context "trimming" do
    it "results in an svg file" do
      file_processor = described_class.new(@temp_dir, hash, source)
      file_processor.write
      file_processor.compile
      file_processor.trim_svg
      expect(File.exist?(svgpath)).to eq(true)
    end
    it "raises an error if the target svg does not exist" do
      file_processor = described_class.new(@temp_dir, hash, source)
      expect { file_processor.trim_svg }.to raise_error(RuntimeError)
    end
  end
  context "integration with lilypond" do
    it "puts output in the target directory even if it's deeply nested" do
      path = "#{@temp_dir}/foo/bar/baz/whatever"
      FileUtils.mkdir_p(path)
      file_processor = described_class.new(path, hash, source)
      file_processor.write
      file_processor.compile
      expect(File.exist?("#{path}/#{hash}.svg")).to eq(true)
    end
  end
end

RSpec.shared_context 'temp_dir_with_midi' do
  around do |example|
    Dir.mktmpdir do |dir|
      @temp_dir = dir
      example.run
    end
  end

  attr_reader :temp_dir

  let(:source) { '\version "2.14.1" \score { { c d e f g a b c } \midi { } }' }
  let(:hash) { "f95206924ddb60916690c047a2345b87" }
  let(:sourcepath) { "#{@temp_dir}/f95206924ddb60916690c047a2345b87.ly" }
  let(:svgpath) { "#{@temp_dir}/f95206924ddb60916690c047a2345b87.svg" }
  let(:mp3path) { "#{@temp_dir}/f95206924ddb60916690c047a2345b87.mp3" }
  let(:barepath) { "#{@temp_dir}/f95206924ddb60916690c047a2345b87" }
end

RSpec.describe(Jekyll::Lilypond::FileProcessor) do
  include_context 'temp_dir_with_midi'

  context "making mp3" do
    it "results in an mp3 file" do
      file_processor = described_class.new(@temp_dir, hash, source)
      file_processor.write
      file_processor.compile
      file_processor.make_mp3
      expect(File.exist?(mp3path)).to eq(true)
    end
    it "doesn't touch a target mp3 that already exists" do
      File.open(mp3path, "w") do |f|
        f.write("This should not be overwritten")
      end
      file_processor = described_class.new(@temp_dir, hash, source)
      file_processor.write
      file_processor.compile
      file_processor.make_mp3
      expect(File.open(mp3path).read).to eq("This should not be overwritten")
    end
    it "errors sensibly if its midi dependency doesn't exist" do
      file_processor = described_class.new(@temp_dir, hash, source)
      expect { file_processor.make_mp3 }.to raise_error(RuntimeError)
    end
  end

  context "integration with lilypond" do
    it "puts output in the target directory even if it's deeply nested" do
      path = "#{@temp_dir}/foo/bar/baz/whatever"
      FileUtils.mkdir_p(path)
      file_processor = described_class.new(path, hash, source)
      file_processor.write
      file_processor.compile
      expect(File.exist?("#{path}/#{hash}.midi")).to eq(true)
    end
  end
  #To do: Error handling
  #To do: Flexible lilypond invocation
  #To do: Do lilypond's products end up in the right place?
end

