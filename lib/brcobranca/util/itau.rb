# frozen_string_literal: true

module Brcobranca
  module Util
    # Regras de calculo de digito verificador (DAC) compartilhadas entre as
    # implementacoes de Boleto e Remessa/Retorno CNAB do Itau (341), para
    # evitar duplicacao e manter as duas em sincronia.
    module Itau
      # Carteiras cujo DAC do nosso numero e calculado apenas com
      # "carteira/nosso_numero", sem agencia/conta.
      CARTEIRAS_SEM_AGENCIA_CONTA = %w[112 126 131 146 150 168].freeze

      module_function

      # Digito verificador (modulo 10) da agencia/conta corrente.
      #
      # @return [Integer]
      def agencia_conta_corrente_dv(agencia, conta_corrente)
        "#{agencia}#{conta_corrente}".modulo10
      end

      # Digito verificador (modulo 10) do nosso numero.
      #
      # Para a grande maioria das carteiras, e calculado sobre
      # "agencia/conta_corrente/carteira/nosso_numero". Excecao: carteiras em
      # CARTEIRAS_SEM_AGENCIA_CONTA, calculado apenas sobre
      # "carteira/nosso_numero".
      #
      # @return [Integer]
      def nosso_numero_dv(agencia, conta_corrente, carteira, nosso_numero)
        if CARTEIRAS_SEM_AGENCIA_CONTA.include?(carteira.to_s)
          "#{carteira}#{nosso_numero}".modulo10
        else
          "#{agencia}#{conta_corrente}#{carteira}#{nosso_numero}".modulo10
        end
      end
    end
  end
end
