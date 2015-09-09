# -*- encoding: utf-8 -*-
module Brcobranca
  module Boleto
    class Sicoob < Base # Sicoob (Bancoob)
      validates_length_of :agencia, maximum: 4, message: "deve ser menor ou igual a 4 dígitos."
      validates_length_of :conta_corrente, maximum: 8, message: "deve ser menor ou igual a 8 dígitos."
      validates_length_of :numero_documento, maximum: 7, message: "deve ser menor ou igual a 7 dígitos."
      validates_length_of :convenio, maximum: 7, message: 'deve ser menor ou igual a 7 dígitos.'

      def initialize(campos = {})
        campos = { carteira: "1" }.merge!(campos)
        super(campos)
      end

      # Codigo do banco emissor (3 dígitos sempre)
      #
      # @return [String] 3 caracteres numéricos.
      def banco
        "756"
      end

      # Dígito verificador do banco
      #
      # @return [String] 1 caractere.
      def banco_dv
        "0"
      end

      # Agência
      #
      # @return [String] 4 caracteres numéricos.
      def agencia=(valor)
        @agencia = valor.to_s.rjust(4, "0") if valor
      end


      # Convênio
      #
      # @return [String] 7 caracteres numéricos.
      def convenio=(valor)
        @convenio = valor.to_s.rjust(7, "0") if valor
      end

      # Número documento
      #
      # @return [String] 7 caracteres numéricos.
      def numero_documento=(valor)
        @numero_documento = valor.to_s.rjust(7, "0") if valor
      end

      # Nosso número para exibição no boleto.
      #
      # @return [String] 8 caracteres numéricos.
      def nosso_numero_boleto
        "#{numero_documento}#{nosso_numero_dv}"
      end

      # 3.13. Nosso número: Código de controle que permite ao Sicoob e à empresa identificar os dados da cobrança que deu origem ao boleto.
      #
      # Para o cálculo do dígito verificador do nosso número, deverá ser utilizada a fórmula abaixo:
      # Número da Cooperativa    9(4) – vide planilha "Capa" deste arquivo
      # Código do Cliente   9(10) – vide planilha "Capa" deste arquivo
      # Nosso Número   9(7) – Iniciado em 1
      #
      # Constante para cálculo  = 3197
      #
      # a) Concatenar na seqüência completando com zero à esquerda.
      #     Ex.:Número da Cooperativa  = 0001
      #           Número do Cliente  = 1-9
      #           Nosso Número  = 21
      #           000100000000190000021
      #
      # b) Alinhar a constante com a seqüência repetindo de traz para frente.
      #     Ex.: 000100000000190000021
      #          319731973197319731973
      #
      # c) Multiplicar cada componente da seqüência com o seu correspondente da constante e somar os resultados.
      #     Ex.: 1*7 + 1*3 + 9*1 + 2*7 + 1*3 = 36
      #
      # d) Calcular o Resto através do Módulo 11.
      #     Ex.: 36/11 = 3, resto = 3
      #
      # e) O resto da divisão deverá ser subtraído de 11 achando assim o DV (Se o Resto for igual a 0 ou 1 então o DV é igual a 0).
      #     Ex.: 11 – 3 = 8, então Nosso Número + DV = 21-8
      #
      def nosso_numero_dv
        "#{agencia}#{convenio}#{numero_documento}".modulo11(
          multiplicador: [3, 1, 9, 7],
          mapeamento: { 1 => 0 }
        ) { |t| 11 - (t % 11) }
      end

      # Modalidade de cobrança
      #
      # @return [String] 2 caracteres numéricos.
      def modalidade_cobranca
        "01"
      end

      # Número da parcela do título
      #
      # @return [String] 3 caracteres numéricos.
      def parcela_titulo
        "001"
      end

      def agencia_conta_boleto
        "#{agencia} / #{convenio}"
      end

      def codigo_barras_segunda_parte
        "#{carteira}#{agencia}#{modalidade_cobranca}#{convenio}#{nosso_numero_boleto}#{parcela_titulo}"
      end
    end
  end
end
