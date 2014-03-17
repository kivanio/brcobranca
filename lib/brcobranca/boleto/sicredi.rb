# -*- encoding: utf-8 -*-
module Brcobranca
  module Boleto
    class Sicredi < Base # Banco SICREDI
      # <b>REQUERIDO</b>: Código do posto da cooperativa de crédito
      attr_accessor :posto

      # <b>REQUERIDO</b>: Byte de identificação do cedente do bloqueto utilizado para compor o nosso número.
      attr_accessor :byte_idt

      validates_length_of :agencia, :maximum => 4, :message => 'deve ser menor ou igual a 4 dígitos.'
      validates_length_of :numero_documento, :maximum => 5, :message => 'deve ser menor ou igual a 5 dígitos.'
      validates_length_of :conta_corrente, :maximum => 5, :message => 'deve ser menor ou igual a 5 dígitos.'
      validates_length_of :carteira, :maximum => 2, :message => 'deve ser menor ou igual a 2 dígitos.'

      # Nova instancia do Bradesco
      # @param (see Brcobranca::Boleto::Base#initialize)
      def initialize(campos={})
        campos = {:carteira => '03', :especie_documento => 'A'}.merge!(campos)
        super(campos)
      end

      # Codigo do banco emissor (3 dígitos sempre)
      #
      # @return [String] 3 caracteres numéricos.
      def banco
        '748'
      end

      # Carteira
      #
      # @return [String] 2 caracteres numéricos.
      def carteira=(valor)
        @carteira = valor.to_s.rjust(2,'0') if valor
      end

      # Posto
      #
      # @return [String] 2 caracteres numéricos.
      def posto=(valor)
        @posto = valor.to_s.rjust(2, '0') if valor
      end

      # Número da conta corrente
      # @return [String] 5 caracteres numéricos.
      def conta_corrente=(valor)
        @conta_corrente = valor.to_s.rjust(5,'0') if valor
      end

      # Dígito verificador do banco
      # @return [String] 1 caractere.
      def banco_dv
        'X'
      end

      # Nosso número para exibir no boleto.
      # @return [String]
      # @example
      #  boleto.nosso_numero_boleto #=> "06/00000004042-8"
      def nosso_numero_boleto
        "#{numero_documento_with_byte_idt[0..1]}/#{numero_documento_with_byte_idt[2..-1]}-#{self.nosso_numero_dv}"
      end

      def numero_documento_with_byte_idt
        "#{self.data_documento.strftime('%y')}#{self.byte_idt}#{self.numero_documento}"
      end

      # Número seqüencial utilizado para identificar o boleto.
      # @return [String] 5 caracteres numéricos.
      def numero_documento=(valor)
        @numero_documento = valor.to_s.rjust(5,'0') if valor
      end

      # Codigo referente ao tipo de cobrança
      # @return [String]: 1 caractere numérico
      def tipo_cobranca
        '3'
      end

      # Codigo referente ao tipo de carteira
      # @return [String]: 1 caractere numérico
      def tipo_carteira
        if self.carteira == '03'
          '1'
        end
      end
      # Dígito verificador do nosso número
      # @return [Integer] 1 caracteres numéricos.
      def nosso_numero_dv
        "#{agencia_posto_conta}#{numero_documento_with_byte_idt}".modulo11_9to2
      end

      def agencia_conta_boleto
        "#{self.agencia}.#{self.posto}.#{conta_corrente}"
      end

      def agencia_posto_conta
        "#{self.agencia}#{self.posto}#{conta_corrente}"
      end

      # Segunda parte do código de barras.
      def codigo_barras_segunda_parte
        campo_livre = "#{self.tipo_cobranca}#{self.tipo_carteira}#{self.nosso_numero_boleto.gsub(/\D/, '')}#{self.agencia_posto_conta}10"
        campo_livre + campo_livre.modulo11_9to2_10_como_zero.to_s
      end
    end
  end
end
