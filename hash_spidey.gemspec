# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hash_spidey/version'

Gem::Specification.new do |spec|
  spec.name          = "hash_spidey"
  spec.version       = HashSpidey::VERSION
  spec.authors       = ["dannguyen"]
  spec.email         = ["dansonguyen@gmail.com"]
  spec.description   = %q{An implementation of Artsy's joeyAghion's Spidey::AbstractSpider}
  spec.summary       = %q{Uses a Hash object to store crawling process, which it can then dump to an external store}
  spec.homepage      = "http://github.com/dannguyen"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"


  spec.add_dependency 'spidey', '~> 0.1'
  spec.add_dependency 'hashie'
  spec.add_dependency 'addressable'

end
