# -*- encoding: utf-8 -*-
#
module Brcobranca
  module Boleto
    class Banpara < Base # Banco BANPARA
      validates_length_of :agencia, maximum: 4, message: 'deve ser menor ou igual a 4 dígitos.'
      validates_length_of :numero_documento, maximum: 11, message: 'deve ser menor ou igual a 11 dígitos.'
      validates_length_of :conta_corrente, maximum: 8, message: 'deve ser menor ou igual a 8 dígitos.'

      # Nova instancia do Banpara
      # @param (see Brcobranca::Boleto::Base#initialize)
      def initialize(campos = {})
        campos[:local_pagamento] = 'Pagar preferencialmente em agência do Banpará'

        super(campos)
      end

      # Codigo do banco emissor (3 dígitos sempre)
      #
      # @return [String] 3 caracteres numéricos.
      def banco
        '037'
      end

      # Dígito verificador do banco
      # @return [Integer] 1 caracteres numéricos.
      def banco_dv
        '1'
      end

      # Aceite - Nao tem no manual, foi baseado em boleto modelo enviado pela prefeitura
      # @return [String] 1 caracteres.
      def aceite
        'N'
      end

      # Espécie do documento - Nao tem no manual, foi baseado em boleto modelo enviado pela prefeitura
      # @return [String] 3 caracteres.
      def especie_documento
        'DAM'
      end

      # Carteira
      #
      # @return [String] CR de acordo com novo layout que banco enviou
      def carteira
        'CR'
      end

      # Conta corrente.
      # @return [String] 8 caracteres numéricos.
      def conta_corrente=(valor)
        @conta_corrente = valor.to_s.rjust(8, '0') if valor
      end

      # Número seqüencial utilizado para identificar o boleto.
      # @return [String] 11 caracteres numéricos.
      def numero_documento=(valor)
        @numero_documento = valor.to_s.rjust(8, '0') if valor
      end

      # Nosso número para exibir no boleto.
      # @return [String]
      # @example
      #  boleto.nosso_numero_boleto #=> "06040428"
      def nosso_numero_boleto
        numero_documento
      end

      # Dígito verificador da agência
      # @return [Integer] 1 caracteres numéricos.
      def agencia_dv
        agencia.modulo11(
          multiplicador: [2, 3, 4, 5],
          mapeamento: { 10 => 'P', 11 => 0 }
        ) { |total| 11 - (total % 11) }
      end

      # Dígito verificador da conta corrente
      # @return [Integer] 1 caracteres numéricos.
      def conta_corrente_dv
        conta_corrente.modulo11(
          multiplicador: [2, 3, 4, 5, 6, 7],
          mapeamento: { 10 => 'P', 11 => 0 }
        ) { |total| 11 - (total % 11) }
      end

      # Agência + conta corrente do cliente para exibir no boleto.
      # @return [String]
      # @example
      #   Código da Agência = 0054
      #   Conta de Cobrança= 6666666
      #   Convênio=12345
      #   Composição do Campo = 00546666666/12345
      def agencia_conta_boleto
        "#{agencia}#{conta_corrente}/#{convenio}"
      end

      def nosso_numero_cod_barra
        nosso_numero_boleto.to_s.rjust(13, '0')
      end

      # Segunda parte do código de barras.
      #
      # NOVO LAYOUT Q O PROPRIO BANCO ENVIOU
      # Posição | Tamanho | Conteúdo
      # 20 a 26 | 7       |  fixo 0000999
      # 27 a 31 | 5       |  Convenio
      # 32 a 44 | 13      |  Nosso Numero com Zeros a esquerda
      #
      # @return [String] 25 caracteres numéricos.

      def codigo_barras_segunda_parte
        "0000999#{convenio}#{nosso_numero_cod_barra}"
      end
    end
  end
end