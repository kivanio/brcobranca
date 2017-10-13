# -*- encoding: utf-8 -*-
module Brcobranca
  module Boleto
    class Cecred < BancoBrasil # Cecred

      validates_length_of :conta_cooperativa, :maximum => 8, :message => "deve ser menor ou igual a 8 dígitos."

      # Conta corrente na cooperativa
      # @return [String] 8 caracteres numéricos.
      def conta_cooperativa=(valor)
        @conta_cooperativa = valor.to_s.rjust(8,'0') if valor
      end

      # Dígito verificador do nosso número.
      # @return [String] 1 caracteres numéricos.
      # @see Cecred#numero_documento
      def nosso_numero_dv
        "#{conta_cooperativa}#{numero_documento}".modulo11(mapeamento: { 10 => 'X' })
      end

      # Nosso número para exibir no boleto.
      # @return [String]
      # @example
      #  boleto.nosso_numero_boleto #=> "12387989000004042-4"
      def nosso_numero_boleto
        "#{conta_cooperativa}#{numero_documento}"
      end
    end
  end
end
