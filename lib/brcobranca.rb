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
  gem 'active_model', ">= 3.0.0"
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

  # Configurações do Brcobranca.
  #
  # Para mudar as configurações padrão, você pode fazer assim:
  # config/environments/test.rb:
  #
  #     Brcobranca.configure do |config|
  #       config.formato = :gif
  #     end
  #
  # Ou colocar em um arquivo na pasta initializer do rails.
  class Configuration
    # Somente rghost até o momento
    attr_accessor :gerador
    # Pode ser pdf, jpg e ps.
    # @see http://wiki.github.com/shairontoledo/rghost/supported-devices-drivers-and-formats Veja mais formatos na documentação do rghost.
    attr_accessor :formato

    # Resolução em pixels do arquivo gerado
    attr_accessor :resolucao

    def initialize #:nodoc:
      self.gerador = :rghost
      self.formato = :pdf
      self.resolucao = 150
    end
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.setup
    yield(configuration)
  end

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