# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "brcobranca/version"

Gem::Specification.new do |gem|
  gem.name        = "brcobranca"
  gem.version     = Brcobranca::VERSION
  gem.platform    = Gem::Platform::RUBY
  gem.authors = ["Kivanio Barbosa"]
  gem.date = %q{2013-06-17}
  gem.description = %q{Gem para emissão de bloquetos de cobrança de bancos brasileiros.}
  gem.summary = %q{Gem que permite trabalhar com bloquetos de cobrança para bancos brasileiros.}
  gem.email = %q{kivanio@gmail.com}
  gem.homepage = %q{http://rubygems.org/gems/brcobranca}

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.requirements = ["GhostScript > 9.0, para gear PDF e código de Barras"]

  # Gems that must be installed for sift to compile and build
  gem.add_development_dependency 'pry', '~> 0.10.0'
  gem.add_development_dependency 'rspec', '~> 3.0.0'
  gem.add_development_dependency 'rake'

  # Gems that must be intalled for sift to work
  gem.add_dependency 'rghost', '0.9.3'
  gem.add_dependency 'rghost_barcode', '~> 0.9'
  gem.add_dependency 'parseline', '~> 1.0.3'
  gem.add_dependency 'activemodel', '>= 3'
end
