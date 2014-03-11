# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "brcobranca/version"

Gem::Specification.new do |s|
  s.name        = "brcobranca"
  s.version     = Brcobranca::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors = ["Kivanio Barbosa"]
  s.date = %q{2013-06-17}
  s.description = %q{Gem para emissão de bloquetos de cobrança de bancos brasileiros.}
  s.summary = %q{Gem que permite trabalhar com bloquetos de cobrança para bancos brasileiros.}
  s.email = %q{kivanio@gmail.com}
  s.homepage = %q{http://rubygems.org/gems/brcobranca}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.requirements = ["GhostScript > 8.0, para gear PDF e código de Barras"]
  s.rubyforge_project = "brcobranca"

  s.add_runtime_dependency(%q<rghost>, ["~> 0.9"])
  s.add_runtime_dependency(%q<rghost_barcode>, ["~> 0.9"])
  s.add_runtime_dependency(%q<parseline>, [">= 1.0.3"])
  s.add_runtime_dependency(%q<activemodel>, [">= 3"])

  s.post_install_message = %[
    ===========================================================================
    Visite http://www.boletorails.com.br para ver exemplos!
    ===========================================================================
  ]
end
