# -*- encoding: utf-8 -*-
#
module Brcobranca
  module Boleto
    class Banpara < Base # Banco BANPARA
      validates_length_of :agencia, maximum: 4, message: 'deve ser menor ou igual a 4 dígitos.'
      validates_length_of :numero_documento, maximum: 11, message: 'deve ser menor ou igual a 11 dígitos.'
      validates_length_of :conta_corrente, maximum: 8, message: 'deve ser menor ou igual a 8 dígitos.'
      validates_length_of :carteira, maximum: 4, message: 'deve ser menor ou igual a 4 dígitos.'

      # Nova instancia do Banpara
      # @param (see Brcobranca::Boleto::Base#initialize)
      def initialize(campos = {})
        campos = { carteira: '06' }.merge!(campos)

        campos[:local_pagamento] = 'Pagável em qualquer Banco até o vencimento'

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
      # @return [String] 4 caracteres numéricos.
      def carteira=(valor)
        @carteira = valor.to_s.rjust(4, '0') if valor
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

      # Dígito verificador do nosso número
      # @return [Integer] 1 caracteres numéricos.
      def nosso_numero_dv
        "#{carteira}#{numero_documento}".modulo11(
          multiplicador: [2, 3, 4, 5, 6, 7],
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
      #  boleto.agencia_conta_boleto #=> "0548 / 00001448-6"
      def agencia_conta_boleto
        "#{agencia} / #{conta_corrente}-#{conta_corrente_dv}"
      end

      # Segunda parte do código de barras.
      #
      # Posição | Tamanho | Conteúdo<br/>
      # 20 a 23 | 4       |  Agência Cedente (Sem o digito verificador, completar com zeros a esquerda quando  necessário)<br/>
      # 24 a 27 | 4       |  Carteira<br/>
      # 28 a 35 | 8       |  Número do Nosso Número(Sem o digito verificador)<br/>
      # 36 a 43 | 8       |  Conta do Cedente (Sem o digito verificador, completar com zeros a esquerda quando necessário)<br/>
      # 44 a 44 | 1       |  Zero<br/>
      #
      # @return [String] 25 caracteres numéricos.

      def codigo_barras_segunda_parte
        "#{agencia}#{carteira}#{numero_documento}#{conta_corrente}0"
      end
    end
  end
end
