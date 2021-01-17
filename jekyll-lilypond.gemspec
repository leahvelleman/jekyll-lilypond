lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "jekyll-lilypond/version"

Gem::Specification.new do |spec|
  spec.name = "jekyll-lilypond"
  spec.summary = "Lilypond music snippets in Jekyll"
  spec.require_paths = ["lib"]
  spec.add_dependency "jekyll", ">= 3.0", "< 5.0"
  spec.add_development_dependency "rspec", "~> 3.5"
end


