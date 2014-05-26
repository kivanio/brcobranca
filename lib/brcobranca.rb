# -*- encoding: utf-8 -*-
$:.push File.join(File.dirname(__FILE__))
require 'brcobranca/calculo'
require 'brcobranca/limpeza'
require 'brcobranca/formatacao'
require 'brcobranca/calculo_data'
require 'brcobranca/currency'

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
  gem 'active_model', '>= 3.0.0'
  require 'active_model'
end


module Brcobranca
  # Exception lançada quando algum tipo de boleto soicitado ainda não tiver sido implementado.
  class NaoImplementado < NotImplementedError
  end

  # Exception lançada quando os dados informados para o boleto estão inválidos.
  #
  # Você pode usar assim na sua aplicação:
  #   rescue Brcobranca::BoletoInvalido => invalido
  #   puts invalido.errors
  class BoletoInvalido < StandardError

    # Atribui o objeto boleto e pega seus erros de validação
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
  #     Brcobranca.setup do |config|
  #       config.formato = :gif
  #     end
  #
  # Ou colocar em um arquivo na pasta initializer do rails.
  class Configuration
    # Gerador de arquivo de boleto.
    # @return [Symbol]
    # @param  [Symbol] (Padrão: :rghost)
    attr_accessor :gerador
    # Formato do arquivo de boleto a ser gerado.
    # @return [Symbol]
    # @param  [Symbol] (Padrão: :pdf)
    # @see http://wiki.github.com/shairontoledo/rghost/supported-devices-drivers-and-formats Veja mais formatos na documentação do rghost.
    attr_accessor :formato

    # Resolução em pixels do arquivo gerado.
    # @return [Integer]
    # @param  [Integer] (Padrão: 150)
    attr_accessor :resolucao

    # Ajusta o Encoding externo (do arquivo) - Ruby 1.9
    # Ex: Caso esteja dando UndefinedConversionError - from ASCII-8BIT to UTF-8
    # configurar com a string 'ascii-8bit'
    # @return [String]
    # @param  [String] (Padrão: nil)
    attr_accessor :external_encoding

    # Atribui valores padrões de configuração
    def initialize
      self.gerador = :rghost
      self.formato = :pdf
      self.resolucao = 150
    end
  end

  # Atribui os valores customizados para as configurações.
  def self.configuration
    @configuration ||= Configuration.new
  end

  # Bloco para realizar configurações customizadas.
  def self.setup
    yield(configuration)
  end

  # Módulo para classes de boletos
  module Boleto
    autoload :Base,          'brcobranca/boleto/base'
    autoload :BancoBrasil,   'brcobranca/boleto/banco_brasil'
    autoload :Itau,          'brcobranca/boleto/itau'
    autoload :Hsbc,          'brcobranca/boleto/hsbc'
    autoload :Real,          'brcobranca/boleto/real'
    autoload :Bradesco,      'brcobranca/boleto/bradesco'
    autoload :Unibanco,      'brcobranca/boleto/unibanco'
    autoload :Caixa,         'brcobranca/boleto/caixa'
    autoload :Sicredi,       'brcobranca/boleto/sicredi'
    autoload :Santander,     'brcobranca/boleto/santander'

    # Módulos para classes de template
    module Template
      autoload :Base,   'brcobranca/boleto/template/base'
      autoload :Rghost, 'brcobranca/boleto/template/rghost'
      autoload :RghostCarne, 'brcobranca/boleto/template/rghost_carne'
    end
  end

  # Módulos para classes de retorno bancário
  module Retorno
    autoload :Base,           'brcobranca/retorno/base'
    autoload :RetornoCbr643,  'brcobranca/retorno/retorno_cbr643'
    autoload :RetornoCnab240,  'brcobranca/retorno/retorno_cnab240'
    autoload :RetornoCnab400,  'brcobranca/retorno/retorno_cnab400'
  end
end

