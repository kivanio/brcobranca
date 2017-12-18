# -*- encoding: utf-8 -*-
#
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'brcobranca/version'

Gem::Specification.new do |gem|
  gem.name        = 'brcobranca'
  gem.version     = Brcobranca::VERSION
  gem.authors = ['Kivanio Barbosa']
  gem.description = 'Gem para emissao de bloquetos de cobranca de bancos brasileiros.'
  gem.summary = 'Gem que permite trabalhar com bloquetos de cobranca para bancos brasileiros.'
  gem.email = 'kivanio@gmail.com'
  gem.homepage = 'http://rubygems.org/gems/brcobranca'
  gem.files         = Dir['Rakefile', '{bin,lib,spec}/**/*', 'README*', 'LICENSE*', 'CHANGELOG*', 'History*'] & `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.requirements = ['GhostScript > 9.0, para gear PDF e código de Barras']

  gem.required_ruby_version = '>= 1.9'

  # Gems that must be intalled for sift to work
  gem.add_dependency 'rghost', '~> 0.9'
  gem.add_dependency 'rghost_barcode', '~> 0.9'
  gem.add_dependency 'parseline', '~> 1.0.3'
  gem.add_dependency 'unidecoder', '>= 1.1.2'
end
