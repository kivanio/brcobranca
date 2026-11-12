# frozen_string_literal: true

module Brcobranca
  module Boleto
    # Banco BTG Pactual (208)
    #
    # Regras do "Manual de Implantação CNAB de Cobrança FEBRABAN-240" v2.2.5 do BTG
    # (docs/BtgPactual), seções 4.1 a 4.4.4.
    class BtgPactual < Base
      validates_length_of :agencia, maximum: 4, message: 'deve ser menor ou igual a 4 dígitos.'
      validates_length_of :nosso_numero, maximum: 11, message: 'deve ser menor ou igual a 11 dígitos.'
      validates_length_of :conta_corrente, maximum: 7, message: 'deve ser menor ou igual a 7 dígitos.'
      validates_length_of :carteira, maximum: 2, message: 'deve ser menor ou igual a 2 dígitos.'

      # Nova instancia do BTG Pactual
      # @param (see Brcobranca::Boleto::Base#initialize)
      def initialize(campos = {})
        campos = { carteira: '01' }.merge!(campos)
        super(campos)
      end

      # Codigo do banco emissor (3 dígitos sempre)
      #
      # @return [String] 3 caracteres numéricos.
      def banco
        '208'
      end

      # Dígito verificador do banco, exibido como "208-1" na ficha de compensação
      # (máscara do kit). O módulo 11 padrão de Base#banco_dv daria 9.
      #
      # @return [String] 1 caractere numérico.
      def banco_dv
        '1'
      end

      # Carteira
      #
      # @return [String] 2 caracteres numéricos.
      def carteira=(valor)
        @carteira = valor.to_s.rjust(2, '0') if valor
      end

      # Conta corrente do beneficiário (sem dígito)
      #
      # @return [String] 7 caracteres numéricos.
      def conta_corrente=(valor)
        @conta_corrente = valor.to_s.rjust(7, '0') if valor
      end

      # Número sequencial utilizado para identificar o boleto.
      #
      # @return [String] 11 caracteres numéricos.
      def nosso_numero=(valor)
        @nosso_numero = valor.to_s.rjust(11, '0') if valor
      end

      # Dígito verificador do nosso número (seção 4.4.4 do manual).
      #
      # Módulo 11 com pesos de 2 a 7 sobre carteira + nosso número:
      # resto 1 => 'P', resto 0 => 0, demais => 11 - resto.
      #
      # @return [String, Integer] 1 caractere.
      def nosso_numero_dv
        "#{carteira}#{nosso_numero}".modulo11(
          multiplicador: [2, 3, 4, 5, 6, 7],
          mapeamento: { 10 => 'P', 11 => 0 }
        ) { |total| 11 - (total % 11) }
      end

      # Nosso número para exibir no boleto, no formato da máscara do BTG
      # (carteira com 3 dígitos e nosso número sem zeros à esquerda).
      #
      # @return [String]
      # @example
      #  boleto.nosso_numero_boleto #=> "001/6380-4"
      def nosso_numero_boleto
        "#{carteira.rjust(3, '0')}/#{nosso_numero.sub(/\A0+(?=\d)/, '')}-#{nosso_numero_dv}"
      end

      # Agência + código do beneficiário para exibir no boleto.
      #
      # @return [String]
      # @example
      #  boleto.agencia_conta_boleto #=> "0050 / 0388685"
      def agencia_conta_boleto
        "#{agencia} / #{conta_corrente}"
      end

      # Segunda parte do código de barras (campo livre, seção 4.1 do manual).
      #
      # Posição | Tamanho | Conteúdo<br/>
      # 20 a 23 | 4  | Código da agência (sem dígito)<br/>
      # 24 a 25 | 2  | Código da carteira<br/>
      # 26 a 36 | 11 | Nosso número (sem dígito)<br/>
      # 37 a 43 | 7  | Conta do beneficiário (sem dígito)<br/>
      # 44 a 44 | 1  | Zero fixo<br/>
      #
      # @return [String] 25 caracteres numéricos.
      def codigo_barras_segunda_parte
        "#{agencia}#{carteira}#{nosso_numero}#{conta_corrente}0"
      end
    end
  end
end
