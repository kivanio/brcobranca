# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'brcobranca/version'

Gem::Specification.new do |gem|
  gem.name        = 'brcobranca'
  gem.version     = Brcobranca::VERSION
  gem.authors = ['Kivanio Barbosa']
  gem.description = 'Gem para emissao de boletos e CNABs de bancos brasileiros.'
  gem.summary = 'Gem que permite trabalhar com boletos e CNABs para bancos brasileiros.'
  gem.email = 'kivanio@gmail.com'
  gem.homepage = 'http://rubygems.org/gems/brcobranca'
  gem.files = Dir['Rakefile', '{lib}/**/*', 'README*', 'LICENSE*', 'CHANGELOG*', 'History*']
  gem.require_paths = ['lib']
  gem.required_ruby_version = '>= 2.7.0'

  gem.requirements = ['GhostScript > 9.0, para gerar PDF e código de Barras']

  gem.add_dependency 'activesupport', '>= 5.2.6'
  gem.add_dependency 'parseline', '>= 1.0.3'
  gem.add_dependency 'rghost', '>= 0.9.8'
  gem.add_dependency 'rghost_barcode', '>= 0.9'
  gem.metadata = {
    'rubygems_mfa_required' => 'true'
  }
end
