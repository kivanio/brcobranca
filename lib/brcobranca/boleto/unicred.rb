# frozen_string_literal: true

module Brcobranca
  module Boleto
    # Banco Unicred
    class Unicred < Base
      attr_accessor :conta_corrente_dv

      validates_length_of :agencia, maximum: 4, message:
       'deve ser menor ou igual a 4 dígitos.'
      validates_length_of :nosso_numero, maximum: 10, message:
       'deve ser menor ou igual a 10 dígitos.'
      validates_length_of :conta_corrente, maximum: 9, message:
'deve ser menor ou igual a 9 dígitos.'
      # Carteira com 2(dois) caracteres ( SEMPRE 21 )
      validates_length_of :carteira, maximum: 2, message:
       'deve ser menor ou igual a 2 dígitos.'
      validates_length_of :conta_corrente_dv, maximum: 1, message:
      'deve ser menor ou igual a 1 dígitos.'

      # Nova instancia do Unicred
      # @param (see Brcobranca::Boleto::Base#initialize)
      def initialize(campos = {})
        campos = {
          carteira: '21',
          local_pagamento: 'PAGÁVEL PREFERENCIALMENTE NAS AGÊNCIAS DA UNICRED',
          aceite: 'N'
        }.merge!(campos)
        super(campos)
      end

      # Codigo do banco emissor 3 digitos sempre
      #
      # @return [String] 3 caracteres numericos.
      def banco
        '136'
      end

      # Agência do cliente junto ao banco.
      # @return [String] 4 caracteres numéricos.
      def agencia=(valor)
        @agencia = valor.to_s.rjust(4, '0') if valor
      end

      # Conta corrente
      # @return [String] 9 caracteres numéricos.
      def conta_corrente=(valor)
        @conta_corrente = valor.to_s.rjust(9, '0') if valor
      end

      # Número seqüencial utilizado para identificar o boleto.
      # @return [String] 10 caracteres numéricos.
      def nosso_numero=(valor)
        @nosso_numero = valor.to_s.rjust(10, '0') if valor
      end

      # Dígito verificador do nosso número.
      #
      # @return [String] 1 caracteres numéricos.
      def nosso_numero_dv
        nosso_numero.to_s.modulo11(mapeamento: {
                                     10 => 0,
                                     11 => 0
                                   })
      end

      # Nosso número para exibir no boleto.
      # @return [String]
      # @example
      #  boleto.nosso_numero_boleto #=> "12345678-4"
      def nosso_numero_boleto
        "#{nosso_numero}-#{nosso_numero_dv}"
      end

      # Agência + conta corrente do cliente para exibir no boleto.
      # @return [String]
      # @example
      #  boleto.agencia_conta_boleto #=> "08111 / 536788-8"
      def agencia_conta_boleto
        "#{agencia} / #{conta_corrente}-#{conta_corrente_dv}"
      end

      # Segunda parte do código de barras.
      # Posição    | Tamanho | Picture | Conteúdo
      # 01-03 | 3  | 9(3) | Identificação da instituição financeira - 136
      # 04-04 | 1  | 9 | Código moeda (9 – Real)
      # 05-05 | 1  | 9 | Dígito verificador do código de barras (DV)
      # 06-19 | 14 | 9(4)   | Posições 06 a 09 – fator de vencimento
      #       |    | 9(8)v99 | Posições 10 a 19 – valor nominal do título
      # 20-23 | 4  | 4  | Agência BENEFICIÁRIO (Sem o dígito verificador)
      # 24-33 | 10 | 10 | Conta do BENEFICIÁRIO (Com o dígito verificador)
      # 34–44 | 11 | 11 | Nosso Número (Com o dígito verificador)
      # @return [String] 25 caracteres numéricos.
      def codigo_barras_segunda_parte
        "#{agencia}#{conta_corrente}#{conta_corrente_dv}#{nosso_numero}#{nosso_numero_dv}"
      end
    end
  end
end
