# -*- encoding: utf-8 -*-
module Brcobranca
  module Boleto
    class Mercantil < Base # Banco Mercantil

      validates_length_of :agencia, :maximum => 4, :message => "deve ser menor ou igual a 4 dígitos."
      validates_length_of :conta_corrente, :maximum => 8, :message => "deve ser menor ou igual a 8 dígitos."
      validates_length_of :carteira, :maximum => 2, :message => "deve ser menor ou igual a 2 dígitos."
      validates_length_of :numero_documento, :maximum => 11, :message => "deve ser menor ou igual a 11 dígitos."
      validates_presence_of :conta_corrente, :message => "não pode ser branco"

      # Nova instancia do Banco Mercantil
      # @param (see Brcobranca::Boleto::Base#initialize)
      def initialize(campos={})
        campos = {:carteira => "06", :codigo_servico => false}.merge!(campos)
        super(campos)
      end

      # Codigo do banco emissor (3 dígitos sempre)
      #
      # @return [String] 3 caracteres numéricos.
      def banco
        "389"
      end

      # Carteira
      #
      # @return [String] 2 caracteres numéricos.
      def carteira=(valor)
        @carteira = valor.to_s.rjust(2,'0') unless valor.nil?
      end

      # Número seqüencial utilizado para identificar o boleto.
      # @return [String] 10 caracteres numéricos.
      def numero_documento=(valor)
        @numero_documento = valor.to_s.rjust(10,'0') unless valor.nil?
      end

      # Dígito verificador do nosso número.
      # @return [String] 1 caracteres numéricos.
      # @see #numero_documento
      def nosso_numero_dv
        "#{self.agencia}#{self.numero_documento}".modulo11_mercantil
      end

      # Nosso número para exibir no boleto.
      # @return [String]
      # @example
      #  boleto.nosso_numero_boleto #=> "11600051123"
      def nosso_numero_boleto
        "#{self.numero_documento}"
      end

      # Agência + conta corrente do cliente para exibir no boleto.
      # @return [String]
      # @example
      #  boleto.agencia_conta_boleto #=> "0548 / 000014486"
      def agencia_conta_boleto
        "#{self.agencia} / #{self.conta_corrente.to_s.rjust(9,'0')}"
      end

      # Conta corrente
      # @return [String] 8 caracteres numéricos.
      def conta_corrente=(valor)
        @conta_corrente = valor.to_s.rjust(8,'0') unless valor.nil?
      end

      # Segunda parte do código de barras.
      # @return [String] 25 caracteres numéricos.
      def codigo_barras_segunda_parte
        "#{self.agencia}#{self.numero_documento}#{nosso_numero_dv}#{numero_contrato}#{dac_recebe}"
      end
      
      def dac_recebe
        "#{self.banco}#{self.moeda}#{self.fator_vencimento}#{valor_documento_formatado}#{self.agencia}#{nosso_numero}#{numero_contrato}2".modulo11_mercantil
      end
      
      def numero_contrato
        self.conta_corrente.to_s.rjust(9,'0')
      end
      
      def nosso_numero
        "#{self.numero_documento}#{nosso_numero_dv}"
      end
      
      def codigo_barras
        raise Brcobranca::BoletoInvalido.new(self) unless self.valid?
        codigo = codigo_barras_primeira_parte #18 digitos
        codigo << codigo_barras_segunda_parte #25 digitos
        if codigo =~ /^(\d{4})(\d{39})$/
          codigo_dv = codigo.modulo11_mercantil
          codigo = "#{$1}#{codigo_dv}#{$2}"
          codigo
        else
          raise Brcobranca::BoletoInvalido.new(self)
        end
      end

    end
  end
end