# -*- encoding: utf-8 -*-
#
module Brcobranca
  module Boleto
    class Unicred < Base # Banco Unicred

      validates_length_of :agencia, maximum: 4, message:
       "deve ser menor ou igual a 4 dígitos."
      validates_length_of :nosso_numero, maximum: 10, message:
       "deve ser menor ou igual a 10 dígitos."
      # validates_length_of :conta_corrente, maximum: 5, message:
      #  'deve ser menor ou igual a 5 dígitos.'
      # Carteira com 2(dois) caracteres ( SEMPRE 21 )
      validates_length_of :carteira, maximum: 2, message:
       "deve ser menor ou igual a 2 dígitos."
      validates_length_of :convenio, maximum: 10, message:
       "deve ser menor ou igual a 10 dígitos."

      # Nova instancia do Unicred
      # @param (see Brcobranca::Boleto::Base#initialize)
      def initialize(campos = {})
        campos = {
          carteira: "21",
          local_pagamento: "PAGÁVEL PREFERENCIALMENTE NAS AGÊNCIAS DA UNICRED",
          aceite: "N",
        }.merge!(campos)
        super(campos)
      end

      # Codigo do banco emissor 3 digitos sempre
      #
      # @return [String] 3 caracteres numericos.
      def banco
        "136"
      end

      # Numero da conta corrente
      # @return [String] 9 caracteres numericos.
      def conta_corrente=(valor)
        @conta_corrente = valor.to_s.rjust(9, "0") if valor
      end

      # Codigo Beneficiario
      # @return [String] 5 caracteres numericos.
      def convenio=(valor)
        @convenio = valor.to_s.rjust(5, "0") if valor
      end

      # Digito verificador do banco
      # @return [String] 1 caractere.
      def banco_dv
        "8"
      end

      # Nosso numero para exibir no boleto. Nosso Numero e formado com 11 onze
      # caracteres, sendo 10 digitos para o nosso numero e um digito para o
      # digito verificador. Ex.: 9999999999-D. Obs.: O Nosso Numero e um
      # identificador do boleto, devendo ser atribuido Nosso Numero diferenciado
      # para cada um. D = digito verificador calculado
      # @return [String]
      # @example
      #  boleto.nosso_numero_boleto #=> "9999999999-D"
      def nosso_numero_boleto
        "#{nosso_numero}-#{nosso_numero_dv}"
      end

      def nosso_numero_codigo_barra
        nosso_numero_boleto.gsub(/\D/, '')
      end

      # Numero sequencial utilizado para identificar o boleto.
      # @return [String] 10 caracteres numericos.
      def nosso_numero=(valor)
        @nosso_numero = valor.to_s.rjust(10, '0') if valor
      end

      # Digito verificador do nosso numero
      # @return [Integer] 1 caracteres numericos.
      def nosso_numero_dv
        "#{nosso_numero}".modulo11(mapeamento: mapeamento_para_modulo_11)
      end

      def conta_corrente_codigo_barra
        "#{conta_corrente}#{conta_corrente_dv}"
      end

      # AGENCIA / CODIGO DO BENEFICIARIO: devera ser preenchido com o codigo da
      # agencia, contendo 4 quatro caracteres / Conta Corrente com 10 dez
      # caracteres. Ex. 9999/999999999-9. Obs.: Preencher com zeros a direita
      # quando necessario.
      def agencia_conta_boleto
        "#{agencia} / #{conta_corrente}-#{conta_corrente_dv}"
      end

      # Segunda parte do codigo de barras.
      # Posicao       Tamanho      Conteudo
      # 20 - 23       04      Agencia BENEFICIARIO Sem o digito verificador,
      #                       completar com zeros a esquerda quando necessario
      # 24 - 33       10      Conta do BENEFICIARIO Com o digito verificador -
      #                       Completar com zeros a esquerda quando necessario
      # 34 – 44       11      Nosso Numero Com o digito verificador
      def codigo_barras_segunda_parte
        "#{agencia}#{conta_corrente_codigo_barra}#{nosso_numero_codigo_barra}"
      end

      private

      def mapeamento_para_modulo_11
        {
          10 => 0,
          11 => 0
        }
      end
    end
  end
end
