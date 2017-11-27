# -*- encoding: utf-8 -*-
module Brcobranca
  module Boleto
    class Credisis < Base # CrediSIS
      attr_accessor :codigo_cedente

      validates_presence_of :codigo_cedente, message: 'não pode estar em branco.'

      validates_length_of :agencia, maximum: 4, message: 'deve ser menor ou igual a 4 dígitos.'
      validates_length_of :conta_corrente, maximum: 7, message: 'deve ser menor ou igual a 7 dígitos.'
      validates_length_of :codigo_cedente, is: 4, message: 'deve ser menor ou igual a 4 dígitos.'
      validates_length_of :carteira, is: 2, message: 'deve ser menor ou igual a 2 dígitos.'
      validates_length_of :convenio, is: 7, message: 'deve ser menor ou igual a 7 dígitos.'

      validates_length_of :numero_documento, maximum: 6, message: 'deve ser menor ou igual a 6 dígitos.'


      # Nova instancia do CrediSIS
      # @param (see Brcobranca::Boleto::Base#initialize)
      def initialize(campos = {})
        campos = { carteira: '18', codigo_servico: false }.merge!(campos)
        super(campos)
      end

      # Codigo do banco emissor (3 dígitos sempre)
      #
      # @return [String] 3 caracteres numéricos.
      def banco
        '097'
      end

      # Carteira
      #
      # @return [String] 2 caracteres numéricos.
      def carteira=(valor)
        @carteira = valor.to_s.rjust(2, '0') if valor
      end

      # Dígito verificador do banco
      #
      # @return [String] 1 caracteres numéricos.
      def banco_dv
        banco.modulo11(mapeamento: { 10 => 'X' })
      end

      # Retorna dígito verificador da agência
      #
      # @return [String] 1 caracteres numéricos.
      def agencia_dv
        agencia.modulo11(mapeamento: { 10 => 'X' })
      end

      # Conta corrente
      # @return [String] 8 caracteres numéricos.
      def conta_corrente=(valor)
        @conta_corrente = valor.to_s.rjust(7, '0') if valor
      end

      # Dígito verificador da conta corrente
      # @return [String] 1 caracteres numéricos.
      def conta_corrente_dv
        conta_corrente.modulo11(mapeamento: { 10 => 'X' })
      end

      # Número seqüencial utilizado para identificar o boleto.
      # (Número de dígitos depende do tipo de convênio).
      # @raise  [Brcobranca::NaoImplementado] Caso o tipo de convênio não seja suportado pelo Brcobranca.
      #
      # @overload numero_documento
      #   Nosso Número de 17 dígitos com Convenio de 7 dígitos e código do cooperado de 4 dígitos. (carteira 18)
      #   @return [String] 17 caracteres numéricos.
      def numero_documento=(valor)
        @numero_documento = valor.to_s.rjust(6, '0')
      end

      # Dígito verificador do nosso número.
      # @return [String] 1 caracteres numéricos.
      # @see BancoBrasil#numero
      def nosso_numero_dv
        "#{numero_documento}".modulo11(mapeamento: { 10 => 'X' })
      end

      # Nosso número para exibir no boleto.
      # @return [String]
      # @example
      #  boleto.nosso_numero_boleto #=> "10000000027000095-7"
      def nosso_numero_boleto
        "#{convenio}#{codigo_cedente}#{numero_documento}"
      end

      # Agência + conta corrente do cliente para exibir no boleto.
      # @return [String]
      # @example
      #  boleto.agencia_conta_boleto #=> "0001-9 / 0000002-7"
      def agencia_conta_boleto
        "#{agencia}-#{agencia_dv} / #{conta_corrente}-#{conta_corrente_dv}"
      end

      # Segunda parte do código de barras.
      # @return [String] 25 caracteres numéricos.
      def codigo_barras_segunda_parte
        "00#{convenio}#{codigo_cedente}#{numero_documento}#{carteira}".rjust(25, '0')
      end
    end
  end
end
