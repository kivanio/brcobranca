# -*- encoding: utf-8 -*-
#
require 'brcobranca/calculo'
require 'brcobranca/limpeza'
require 'brcobranca/formatacao'
require 'brcobranca/formatacao_string'
require 'brcobranca/calculo_data'
require 'brcobranca/currency'
require 'brcobranca/validations'
require 'brcobranca/util/date'

module Brcobranca
  # Exception lançada quando algum tipo de boleto soicitado ainda não tiver sido implementado.
  class NaoImplementado < RuntimeError
  end

  class ValorInvalido < StandardError
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

  # Exception lançada quando os dados informados para o arquivo remessa estão inválidos.
  #
  # Você pode usar assim na sua aplicação:
  #   rescue Brcobranca::RemessaInvalida => invalido
  #   puts invalido.errors
  class RemessaInvalida < StandardError
    # Atribui o objeto boleto e pega seus erros de validação
    def initialize(remessa)
      errors = remessa.errors.full_messages.join(', ')
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

    # Ajusta o encoding do texto do boleto enviado para o GhostScript
    # O valor 'ascii-8bit' evita problemas com acentos e cedilha
    # @return [String]
    # @param  [String] (Padrão: nil)
    attr_accessor :external_encoding

    # Atribui valores padrões de configuração
    def initialize
      self.gerador = :rghost
      self.formato = :pdf
      self.resolucao = 150
      self.external_encoding = 'ascii-8bit'
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
    autoload :BancoNordeste, 'brcobranca/boleto/banco_nordeste'
    autoload :BancoBrasil,   'brcobranca/boleto/banco_brasil'
    autoload :BancoBrasilia, 'brcobranca/boleto/banco_brasilia'
    autoload :Itau,          'brcobranca/boleto/itau'
    autoload :Hsbc,          'brcobranca/boleto/hsbc'
    autoload :Bradesco,      'brcobranca/boleto/bradesco'
    autoload :Caixa,         'brcobranca/boleto/caixa'
    autoload :Sicoob,        'brcobranca/boleto/sicoob'
    autoload :Sicredi,       'brcobranca/boleto/sicredi'
    autoload :Unicred,       'brcobranca/boleto/unicred'
    autoload :Santander,     'brcobranca/boleto/santander'
    autoload :Banestes,      'brcobranca/boleto/banestes'
    autoload :Banrisul,      'brcobranca/boleto/banrisul'
    autoload :Credisis,      'brcobranca/boleto/credisis'
    autoload :Cecred,        'brcobranca/boleto/cecred'
    autoload :Safra,         'brcobranca/boleto/safra'
    autoload :Citibank,      'brcobranca/boleto/citibank'

    # Módulos para classes de template
    module Template
      autoload :Base,        'brcobranca/boleto/template/base'
      autoload :Rghost,      'brcobranca/boleto/template/rghost'
      autoload :RghostCarne, 'brcobranca/boleto/template/rghost_carne'
    end
  end

  # Módulos para classes de retorno bancário
  module Retorno
    autoload :Base,            'brcobranca/retorno/base'
    autoload :RetornoCbr643,   'brcobranca/retorno/retorno_cbr643'
    autoload :RetornoCnab240,  'brcobranca/retorno/retorno_cnab240'
    autoload :RetornoCnab400,  'brcobranca/retorno/retorno_cnab400' # DEPRECATED

    module Cnab400
      autoload :Base,          'brcobranca/retorno/cnab400/base'
      autoload :Bradesco,      'brcobranca/retorno/cnab400/bradesco'
      autoload :Banrisul,      'brcobranca/retorno/cnab400/banrisul'
      autoload :Itau,          'brcobranca/retorno/cnab400/itau'
      autoload :BancoNordeste, 'brcobranca/retorno/cnab400/banco_nordeste'
      autoload :BancoBrasilia, 'brcobranca/retorno/cnab400/banco_brasilia'
      autoload :Unicred,       'brcobranca/retorno/cnab400/unicred'
      autoload :Credisis,      'brcobranca/retorno/cnab400/credisis'
      autoload :Santander,     'brcobranca/retorno/cnab400/santander'
      autoload :BancoBrasil,   'brcobranca/retorno/cnab400/banco_brasil'
    end

    module Cnab240
      autoload :Base,          'brcobranca/retorno/cnab240/base'
      autoload :Santander,     'brcobranca/retorno/cnab240/santander'
      autoload :Cecred,        'brcobranca/retorno/cnab240/cecred'
      autoload :Sicredi,       'brcobranca/retorno/cnab240/sicredi'
      autoload :Sicoob,        'brcobranca/retorno/cnab240/sicoob'
      autoload :Caixa,         'brcobranca/retorno/cnab240/caixa'
    end
  end

  # Módulos para as classes que geram os arquivos remessa
  module Remessa
    autoload :Base,            'brcobranca/remessa/base'
    autoload :Pagamento,       'brcobranca/remessa/pagamento'

    module Cnab400
      autoload :Base,          'brcobranca/remessa/cnab400/base'
      autoload :BancoBrasil,   'brcobranca/remessa/cnab400/banco_brasil'
      autoload :Banrisul,      'brcobranca/remessa/cnab400/banrisul'
      autoload :Bradesco,      'brcobranca/remessa/cnab400/bradesco'
      autoload :Itau,          'brcobranca/remessa/cnab400/itau'
      autoload :Citibank,      'brcobranca/remessa/cnab400/citibank'
      autoload :Santander,     'brcobranca/remessa/cnab400/santander'
      autoload :Sicoob,        'brcobranca/remessa/cnab400/sicoob'
      autoload :BancoNordeste, 'brcobranca/remessa/cnab400/banco_nordeste'
      autoload :BancoBrasilia, 'brcobranca/remessa/cnab400/banco_brasilia'
      autoload :Unicred,       'brcobranca/remessa/cnab400/unicred'
      autoload :Credisis,      'brcobranca/remessa/cnab400/credisis'
    end

    module Cnab240
      autoload :Base,               'brcobranca/remessa/cnab240/base'
      autoload :BaseCorrespondente, 'brcobranca/remessa/cnab240/base_correspondente'
      autoload :Caixa,              'brcobranca/remessa/cnab240/caixa'
      autoload :Cecred,             'brcobranca/remessa/cnab240/cecred'
      autoload :BancoBrasil,        'brcobranca/remessa/cnab240/banco_brasil'
      autoload :Sicoob,             'brcobranca/remessa/cnab240/sicoob'
      autoload :SicoobBancoBrasil,  'brcobranca/remessa/cnab240/sicoob_banco_brasil'
      autoload :Sicredi,            'brcobranca/remessa/cnab240/sicredi'
      autoload :Unicred,            'brcobranca/remessa/cnab240/unicred'
    end
  end

  # Módulos para classes de utilidades
  module Util
    autoload :Empresa, 'brcobranca/util/empresa'
    autoload :Errors, 'brcobranca/util/errors'
  end
end
