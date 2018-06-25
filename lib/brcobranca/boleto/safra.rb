# -*- encoding: utf-8 -*-
#

module Brcobranca
  module Boleto
    class Safra < Base # Banco Safra
      # <b>REQUERIDO</b>: Dígito da Agência
      attr_accessor :agencia_dv
      # <b>REQUERIDO</b>: Dígito da conta
      attr_accessor :conta_corrente_dv
      
      validates_presence_of :agencia_dv, :conta_corrente_dv, message: 'não pode estar em branco.'
      validates_length_of :agencia, maximum: 4, message: 'deve ser menor ou igual a 4 dígitos.'
      validates_length_of :nosso_numero, maximum: 8, message: 'deve ser menor ou igual a 8 dígitos.'
      validates_length_of :conta_corrente, maximum: 8, message: 'deve ser menor ou igual a 8 dígitos.'
      validates_length_of :agencia_dv, is: 1, message: 'deve ser igual a 1 dígitos.'
      validates_length_of :conta_corrente_dv, is: 1, message: 'deve ser igual a 1 dígitos.'

      # Codigo do banco emissor (3 dígitos sempre)
      #
      # @return [String] 3 caracteres numéricos.
      def banco
        '422'
      end

      # Agência
      #
      # @return [String] 4 caracteres numéricos.
      def agencia=(valor)
        @agencia = valor.to_s.rjust(4, '0') if valor
      end

      # Conta corrente
      # @return [String] 8 caracteres numéricos.
      def conta_corrente=(valor)
        @conta_corrente = valor.to_s.rjust(8, '0') if valor
      end

      # Número seqüencial utilizado para identificar o boleto.
      # @return [String] 8 caracteres numéricos.
      def nosso_numero=(valor)
        @nosso_numero = valor.to_s.rjust(8, '0') if valor
      end

      # Dígito verificador do nosso número.
      #
      # @return [String] 1 caracteres numéricos.
      def nosso_numero_dv
        nosso_numero.modulo11(
          reverse: false,
          mapeamento: { 10 => 0, 11 => 1 }
        ) { |total| 11 - (total % 11) }
      end

      # Nosso número para exibir no boleto.
      # @return [String]
      # @example
      #  boleto.nosso_numero_boleto #=> "175/12345678-4"
      def nosso_numero_boleto
        "#{nosso_numero}-#{nosso_numero_dv}"
      end

      # Agência + conta corrente do cliente para exibir no boleto.
      # @return [String]
      # @example
      #  boleto.agencia_conta_boleto #=> "08111 / 536788"
      def agencia_conta_boleto
        "#{agencia}#{agencia_dv} / #{conta_corrente}#{conta_corrente_dv}"
      end

      # Segunda parte do código de barras.
      #
      # ORMATAÇÃO DO CÓDIGO DE BARRAS - COBRANÇA REGISTRADA
      # Campo
      # Significado
      #
      # Formato
      # Posições
      # Conteúdo
      # DE
      #
      # ATÉ
      # Banco
      # Banco Beneficiário do boleto
      # 9 (03)
      # 1
      # 3
      # 422
      # Moeda
      # Código da moeda
      # 9 (01)
      # 4
      # 4
      # 9 = real
      # DAC
      # DAC - Dígito de auto conferência
      # 9 (01)
      # 5
      # 5
      # Dígito de auto conferência
      # Fator de Vencimento
      # Data de vencimento do título
      # 9(04)
      # 6
      # 9
      # DV
      # Valor
      # Valor do boleto
      # 9 (10)
      # 10
      # 19
      # Valor do Boleto com zeros a esquerda
      # Campo Livre
      # Sistema
      # 9 (01)
      # 20
      # 20
      # 7 = Dígito do Bco Safra
      # Campo Livre
      # Agência
      # 9 (05)
      # 21
      # 25
      # (05) Agência do cliente Safra
      # Campo Livre
      # Cliente
      # 9 (09)
      # 26
      # 34
      # No da conta
      # Campo Livre
      # Nosso Número
      # 9 (09)
      # 35
      # 43
      # Nosso Número
      # Campo Livre
      # Tipo cobrança
      # 9 (01)
      #
      # 44
      # 44
      #
      # 2 = cobrança registrada
      #
      # @return [String] 25 caracteres numéricos.
      def codigo_barras_segunda_parte
        "7#{agencia}#{agencia_dv}#{conta_corrente}#{conta_corrente_dv}#{nosso_numero}#{nosso_numero_dv}2"
      end
    end
  end
end
