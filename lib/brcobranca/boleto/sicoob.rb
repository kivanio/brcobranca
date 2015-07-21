# -*- encoding: utf-8 -*-
module Brcobranca
  module Boleto
    class Sicoob < Base # Sicoob (Bancoob)
      validates_length_of :agencia, maximum: 4, message: "deve ser menor ou igual a 4 dígitos."
      validates_length_of :conta_corrente, maximum: 8, message: "deve ser menor ou igual a 8 dígitos."
      validates_length_of :numero_documento, maximum: 7, message: "deve ser menor ou igual a 6 dígitos."

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
        "#{Date.today.strftime("%y")}#{numero_documento}"
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
