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
  gem.homepage = 'https://github.com/kivanio/brcobranca'
  gem.files = Dir['Rakefile', '{lib}/**/*', 'README*', 'LICENSE*', 'CHANGELOG*', 'History*']
  gem.require_paths = ['lib']
  gem.required_ruby_version = '>= 2.7.0'

  gem.metadata = {
    'homepage_uri' => 'https://github.com/kivanio/brcobranca',
    'changelog_uri' => 'https://github.com/kivanio/brcobranca/releases',
    'source_code_uri' => 'https://github.com/kivanio/brcobranca',
    'bug_tracker_uri' => 'https://github.com/kivanio/brcobranca/issues',
    'documentation_uri' => 'https://github.com/kivanio/brcobranca/wiki',
    'rubygems_mfa_required' => 'true'
  }

  gem.requirements = ['GhostScript > 9.0, para gerar PDF e código de Barras']

  gem.add_dependency 'fast_blank'
  gem.add_dependency 'parseline', '>= 1.0.3'
  gem.add_dependency 'rghost', '>= 0.9.8'
  gem.add_dependency 'rghost_barcode', '>= 0.9'

  gem.metadata = {
    'rubygems_mfa_required' => 'true'
  }
end
