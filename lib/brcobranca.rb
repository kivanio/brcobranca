# -*- encoding: utf-8 -*-

begin
  require 'date'
rescue LoadError
  require 'rubygems' unless ENV['NO_RUBYGEMS']
  gem 'date'
  require 'date'
end

begin
  require 'active_model'
rescue LoadError
  require 'rubygems' unless ENV['NO_RUBYGEMS']
  gem 'active_model'
  require 'active_model'
end

module Brcobranca

  class NaoImplementado < NotImplementedError
  end

  #   rescue Brcobranca::BoletoInvalido => invalido
  #   puts invalido.errors
  class BoletoInvalido < StandardError

    def initialize(boleto)
      errors = boleto.errors.full_messages.join(', ')
      super(errors)
    end
  end

  autoload :Config,       'brcobranca/config'
  autoload :Calculo,      'brcobranca/calculo'
  autoload :Limpeza,      'brcobranca/limpeza'
  autoload :Formatacao,   'brcobranca/formatacao'
  autoload :CalculoData,  'brcobranca/calculo_data'
  autoload :Currency,     'brcobranca/currency'

  module Boleto
    autoload :Base,         'brcobranca/boleto/base'
    autoload :BancoBrasil,  'brcobranca/boleto/banco_brasil'
    autoload :Itau,         'brcobranca/boleto/itau'
    autoload :Hsbc,         'brcobranca/boleto/hsbc'
    autoload :Real,         'brcobranca/boleto/real'
    autoload :Bradesco,     'brcobranca/boleto/bradesco'
    autoload :Unibanco,     'brcobranca/boleto/unibanco'
    autoload :Banespa,      'brcobranca/boleto/banespa'

    module Template
      autoload :Rghost, 'brcobranca/boleto/template/rghost'
    end
  end

  module Retorno
    autoload :Base,           'brcobranca/retorno/base'
    autoload :RetornoCbr643,  'brcobranca/retorno/retorno_cbr643'
  end
end

case Brcobranca::Config.gerador
when :rghost

  module Brcobranca::Boleto
    Base.class_eval do
      include Brcobranca::Boleto::Template::Rghost
    end
  end

else
  "Configure o gerador na opção 'Brcobranca::Config.gerador' corretamente!!!"
end