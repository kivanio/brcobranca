# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{brcobranca}
  s.version = "2.0.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Kivanio Barbosa"]
  s.date = %q{2009-07-23}
  s.description = %q{Gem para emissão de bloquetos de cobrança de bancos brasileiros.}
  s.email = ["kivanio@gmail.com"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt"]
  s.files = ["History.txt", "Manifest.txt", "README.rdoc", "Rakefile", "brcobranca.gemspec", "lib/brcobranca.rb", "lib/brcobranca/arquivos/logos/bb.jpg", "lib/brcobranca/arquivos/logos/bradesco.jpg", "lib/brcobranca/arquivos/logos/hsbc.jpg", "lib/brcobranca/arquivos/logos/itau.jpg", "lib/brcobranca/arquivos/logos/real.jpg", "lib/brcobranca/arquivos/logos/unibanco.jpg", "lib/brcobranca/arquivos/templates/modelo_generico.eps", "lib/brcobranca/boleto/banco_bradesco.rb", "lib/brcobranca/boleto/banco_brasil.rb", "lib/brcobranca/boleto/banco_hsbc.rb", "lib/brcobranca/boleto/banco_itau.rb", "lib/brcobranca/boleto/banco_real.rb", "lib/brcobranca/boleto/banco_unibanco.rb", "lib/brcobranca/boleto/base.rb", "lib/brcobranca/boleto/template/rghost.rb", "lib/brcobranca/boleto/template/util.rb", "lib/brcobranca/config.rb", "lib/brcobranca/core_ext.rb", "lib/brcobranca/currency.rb", "lib/brcobranca/retorno/base.rb", "lib/brcobranca/retorno/retorno_cbr643.rb", "test/test_banco_bradesco.rb", "test/test_banco_brasil.rb", "test/test_banco_hsbc.rb", "test/test_banco_itau.rb", "test/test_banco_real.rb", "test/test_banco_unibanco.rb", "test/test_base.rb", "test/test_core_ext.rb", "test/test_currency.rb", "test/test_helper.rb", "test/test_retorno_cbr643.rb", "test/test_rghost.rb"]
  s.homepage = %q{http://brcobranca.rubyforge.org}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{brcobranca}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Gem que permite trabalhar com cobranças via bancos brasileiros.}
  s.test_files = ["test/test_banco_bradesco.rb", "test/test_banco_brasil.rb", "test/test_banco_hsbc.rb", "test/test_banco_itau.rb", "test/test_banco_real.rb", "test/test_banco_unibanco.rb", "test/test_base.rb", "test/test_core_ext.rb", "test/test_currency.rb", "test/test_helper.rb", "test/test_retorno_cbr643.rb", "test/test_rghost.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rghost>, [">= 0.8.7"])
      s.add_runtime_dependency(%q<rghost_barcode>, [">= 0.8"])
      s.add_runtime_dependency(%q<parseline>, [">= 1.0.3"])
      s.add_development_dependency(%q<hoe>, [">= 2.3.2"])
    else
      s.add_dependency(%q<rghost>, [">= 0.8.7"])
      s.add_dependency(%q<rghost_barcode>, [">= 0.8"])
      s.add_dependency(%q<parseline>, [">= 1.0.3"])
      s.add_dependency(%q<hoe>, [">= 2.3.2"])
    end
  else
    s.add_dependency(%q<rghost>, [">= 0.8.7"])
    s.add_dependency(%q<rghost_barcode>, [">= 0.8"])
    s.add_dependency(%q<parseline>, [">= 1.0.3"])
    s.add_dependency(%q<hoe>, [">= 2.3.2"])
  end
end
