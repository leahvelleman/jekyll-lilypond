require "jekyll"
require "jekyll-lilypond"
require "spec_helper"
require "tmpdir"

RSpec.describe(Jekyll::Lilypond) do
  around(:each) do |example|
    Dir.mktmpdir do |dir| 
      @temp_dir = dir
      @test_page = "#{@temp_dir}/test_page.md"
      @dest_page = "#{dest_dir}/test_page.html"
      FileUtils.cp_r("spec/fixtures/.", @temp_dir)
      File.open(@test_page, "w") { |f| f.write(test_page_contents) } 
      example.run
    end
  end

  let(:overrides) { {} }
  let(:config) do
    Jekyll.configuration(Jekyll::Utils.deep_merge_hashes({
      "full_rebuild" => true,
      "source"       => @temp_dir,
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


  context "somethingorother" do
    let(:test_page_contents) { 
<<-MD
---
layout: home
---
foobledooble
MD
}
    it "works" do
      expect(File).to exist(@test_page)
      site.process
      expect(File.read(@dest_page)).to include("foobledooble")
    end
  end

  context "used with the vacuous template" do
    let(:test_page_contents) { 
<<-MD
---
layout: vacuous_html
---
{% lilypond source_template: "vacuous_ly", include_template: "basic_html" %}
c d e f g a b c
{% endlilypond %}
MD
}
    before(:each) do site.process end
    it "doesn't just emit the tag contents" do
      expect(File.read(@dest_page)).not_to include("c d e f g a b c")
    end
    it "produces a PNG in the source tree" do
      puts Dir.entries"#{@temp_dir}/lilypond_files"
      expect(File).to exist("#{@temp_dir}/lilypond_files/99cef9f0865c2c21ba7b5b00d1092f61.png")
    end
    it "produces a PNG in the destination tree" do
      expect(File).to exist("#{dest_dir}/lilypond_files/99cef9f0865c2c21ba7b5b00d1092f61.png")
    end
    it "produces an image element in the rendered page" do
      expect(File.read(@dest_page)).to include('<img src="99cef9f0865c2c21ba7b5b00d1092f61.png" />')
    end
  end
end


