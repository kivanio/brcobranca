# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in brcobranca.gemspec
gemspec

# Dependências opcionais do template Prawn (a aplicação adiciona no próprio Gemfile).
# Ficam também no grupo :test porque o CI roda com BUNDLE_WITHOUT=development.
group :development, :test do
  gem 'barby'
  gem 'prawn'
  gem 'rqrcode'
end

group :development do
  gem 'pry'
  gem 'rubocop'
  gem 'rubocop-packaging'
  gem 'rubocop-performance'
  gem 'rubocop-rspec'
end

group :test do
  gem 'code-scanning-rubocop'
  gem 'json'
  gem 'rake'
  gem 'rspec'
  gem 'simplecov'
  gem 'test-prof'
  gem 'timecop'
end
