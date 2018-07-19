# -*- encoding: utf-8 -*-
#
module Brcobranca
  module Boleto
    class BancoNordeste < Base # Banco do Nordeste
      # <b>REQUERIDO</b>: digito verificador da conta corrente
      attr_accessor :digito_conta_corrente

      validates_length_of :agencia, maximum: 4, message: 'deve ser menor ou igual a 4 dígitos.'
      validates_length_of :conta_corrente, maximum: 7, message: 'deve ser menor ou igual a 7 dígitos.'
      validates_length_of :digito_conta_corrente, is: 1, message: 'deve ser igual a 1 dígitos.'
      validates_length_of :carteira, maximum: 2, message: 'deve ser menor ou igual a 2 dígitos.'
      validates_length_of :nosso_numero, maximum: 7, message: 'deve ser menor ou igual a 7 dígitos.'

      # Nova instancia do Banco do Nordeste
      # @param (see Brcobranca::Boleto::Base#initialize)
      def initialize(campos = {})
        campos = { carteira: '21' }.merge!(campos)
        super(campos)
      end

      # Codigo do banco emissor (3 dígitos sempre)
      #
      # @return [String] 3 caracteres numéricos.
      def banco
        '004'
      end

      # Número da conta corrente
      # @return [String] 7 caracteres numéricos.
      def conta_corrente=(valor)
        @conta_corrente = valor.to_s.rjust(7, '0') if valor
      end

      # Número sequencial utilizado para identificar o boleto.
      # @return [String] 7 caracteres numéricos.
      def nosso_numero=(valor)
        @nosso_numero = valor.to_s.rjust(7, '0') if valor
      end

      # Dígito verificador do nosso número.
      # @return [String] 1 caracteres numéricos.
      def nosso_numero_dv
        nosso_numero.modulo11(
          multiplicador: (2..8).to_a,
          mapeamento: { 10 => 0, 11 => 0 }
        ) { |total| 11 - (total % 11) }
      end

      # Nosso número para exibir no boleto.
      # @return [String]
      # @example
      #  boleto.nosso_numero_boleto #=> "0020572-9"
      def nosso_numero_boleto
        "#{nosso_numero}-#{nosso_numero_dv}"
      end

      # Agência + codigo do cedente do cliente para exibir no boleto.
      # @return [String]
      # @example
      #  boleto.agencia_conta_boleto #=> "0059/189977-5"
      def agencia_conta_boleto
        "#{agencia}/#{conta_corrente}-#{digito_conta_corrente}"
      end

      # Segunda parte do código de barras.
      # 9(04) | Agência <br/>
      # 9(08) | Conta corrente com DV <br/>
      # 9(08) | Nosso Numero Com DV<br/>
      # 9(02) | Carteira<br/>
      # 9(03) | Zeros<br/>
      #
      # @return [String] 25 caracteres numéricos.
      def codigo_barras_segunda_parte
        "#{agencia}#{conta_corrente}#{digito_conta_corrente}#{nosso_numero}#{nosso_numero_dv}#{carteira}000"
      end
    end
  end
end
