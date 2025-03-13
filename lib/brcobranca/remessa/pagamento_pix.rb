# frozen_string_literal: true

require 'uri'

module Brcobranca
  module Remessa
    class PagamentoPix < Pagamento
      include Brcobranca::Validations

      # Diretório de Identificadores de Contas Transacionais (DICT)
      # @see https://www.bcb.gov.br/estabilidadefinanceira/dict
      TIPOS_CHAVE_DICT = %w[
        cpf
        cnpj
        email
        telefone
        chave_aleatoria
      ].freeze

      # <b>REQUERIDO</b>: Tipos de chave PIX.
      # @see TIPOS_CHAVE_DICT
      attr_accessor :tipo_chave_pix
      # <b>REQUERIDO</b>: Chave PIX do recebedor
      attr_accessor :chave_pix
      # <b>OPCIONAL</b>: Identificação de Tipo de Pagamento
      attr_accessor :tipo_pagamento_pix
      # <b>OPCIONAL</b>: Quantidade de pagamento possíveis
      attr_accessor :quantidade_pagamentos_pix
      # <b>OPCIONAL</b>: Identifica o tipo do valor informado
      attr_accessor :tipo_valor_pix
      # <b>OPCIONAL</b>: Valor Máximo
      attr_accessor :valor_maximo_pix
      # <b>OPCIONAL</b>: Percentual máximo
      attr_accessor :percentual_maximo_pix
      # <b>OPCIONAL</b>: Valor Mínimo
      attr_accessor :valor_minimo_pix
      # <b>OPCIONAL</b>: Percentual mínimo
      attr_accessor :percentual_minimo_pix
      # <b>OPCIONAL</b>: Código de identificação do Qr Code (TXID)
      attr_accessor :txid_pix

      validates_presence_of :chave_pix, :tipo_chave_pix, message: 'não pode estar em branco.'

      validates_inclusion_of :tipo_chave_pix,
                             in: TIPOS_CHAVE_DICT,
                             message: "precisa ser um dos seguintes: #{TIPOS_CHAVE_DICT.join(', ')}"

      validates_format_of :chave_pix,
                          with: /^\d{11}$/,
                          if: :tipo_chave_cpf?,
                          message: 'deve ter 11 dígitos.'

      validates_format_of :chave_pix,
                          with: URI::MailTo::EMAIL_REGEXP,
                          if: :tipo_chave_email?,
                          message: 'não é válido.'

      validates_format_of :chave_pix,
                          with: /^[\da-zA-Z]{12}\d{2}$/,
                          if: :tipo_chave_cnpj?,
                          message: 'deve ter 14 caracteres.'

      validates_format_of :chave_pix,
                          with: /^\+\d{12,13}$/,
                          if: :tipo_chave_telefone?,
                          message: 'deve estar no formato +55DDNNNNNNNNN.'

      validates_length_of :chave_pix,
                          in: 1..77,
                          if: :tipo_chave_chave_aleatoria?,
                          message: 'deve ter entre 1 e 77 caracteres.'

      def initialize(campos = {})
        padrao = {
          tipo_chave_pix: 'cnpj',
          tipo_pagamento_pix: '00',
          quantidade_pagamentos_pix: '01',
          tipo_valor_pix: '1',
          valor_maximo_pix: 100.0,
          percentual_maximo_pix: 100.0,
          valor_minimo_pix: 100.0,
          percentual_minimo_pix: 100.0,
          txid_pix: nil
        }

        super(padrao.merge!(campos))
      end

      # @param tamanho [Float] tamanho do campo
      def formata_valor_maximo_pix(tamanho = 13)
        format_value(:valor_maximo_pix, tamanho)
      end

      # @param tamanho [Float] tamanho do campo
      def formata_valor_minimo_pix(tamanho = 13)
        format_value(:valor_minimo_pix, tamanho)
      end

      # @param tamanho [Float] tamanho do campo
      def formata_percentual_maximo_pix(tamanho = 5)
        format_value(:percentual_maximo_pix, tamanho)
      end

      # @param tamanho [Float] tamanho do campo
      def formata_percentual_minimo_pix(tamanho = 5)
        format_value(:percentual_minimo_pix, tamanho)
      end

      private

      TIPOS_CHAVE_DICT.each do |tipo|
        define_method(:"tipo_chave_#{tipo}?") do
          tipo_chave_pix == tipo
        end
      end
    end
  end
end
