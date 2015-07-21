# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dromelib/version'

Gem::Specification.new do |spec|
  spec.name          = 'dromelib'
  spec.version       = Dromelib::VERSION
  spec.authors       = ['Fernando Garcia Samblas']
  spec.email         = ['fernando.garcia@the-cocktail.com']
  spec.summary       = 'Personal but transferable semantic closet for our digital worlds.'
  spec.description   = \
    'This software is a Ruby library whose purpose is to let a semantically ' \
    'linked storage of personal data.'
  spec.homepage      = 'http://lasestrellas.de/'
  spec.license       = 'CeCILL'

  # spec.required_ruby_version = '>= 2.2.2'
  # spec.add_dependency 'rails', '>= 5.0.0'
  spec.add_dependency 'gmail'
  spec.add_dependency 'rfc2047'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'climate_control'
  spec.add_development_dependency 'minitest-reporters', '~> 1.0'
end
