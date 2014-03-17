# -*- encoding: utf-8 -*-
module Brcobranca
  module Boleto
    class Real < Base # Banco REAL

      validates_length_of :agencia, :maximum => 4, :message => 'deve ser menor ou igual a 4 dígitos.'
      validates_length_of :conta_corrente, :maximum => 7, :message => 'deve ser menor ou igual a 7 dígitos.'

      validates_each :numero_documento do |record, attr, value|
        record.errors.add attr, 'deve ser menor ou igual a 13 dígitos.' if (value.to_s.size > 13) && (record.carteira.to_i == 57)
        record.errors.add attr, 'deve ser menor ou igual a 7 dígitos.' if (value.to_s.size > 7) && (record.carteira.to_i != 57)
      end

      ## Nova instancia do Real
      # @param (see Brcobranca::Boleto::Base#initialize)
      def initialize(campos={})
        campos = {:carteira => '57'}.merge!(campos)
        super(campos)
      end

      # Codigo do banco emissor (3 dígitos sempre)
      def banco
        '356'
      end

      # Número seqüencial utilizado para identificar o boleto.
      #
      # NUMERO DO BANCO : COM 7 DIGITOS P/ COBRANCA REGISTRADA e ATE 13 DIGITOS P/ COBRANCA SEM REGISTRO
      #
      # @return [String] 7 ou 13 caracteres numéricos.
      def numero_documento
        quantidade = (self.carteira.to_i == 57) ? 13 : 7
        @numero_documento.to_s.rjust(quantidade, '0')
      end

      # Nosso número para exibir no boleto.
      # @return [String]
      # @example
      #  boleto.nosso_numero_boleto #=> "4000403005-6"
      def nosso_numero_boleto
        "#{self.numero_documento}-#{self.nosso_numero_dv}"
      end

      # Número do convênio/contrato do cliente para exibir no boleto.
      # @return [String]
      # @example
      #  boleto.agencia_conta_boleto #=> "0548-7 / 0001448-6"
      def agencia_conta_boleto
        "#{self.agencia}-#{self.agencia_dv} / #{self.conta_corrente}-#{self.conta_corrente_dv}"
      end

      # Dígito verificador do nosso número.
      # @return [String] 1 caracteres numéricos.
      def agencia_conta_corrente_nosso_numero_dv
        "#{self.numero_documento}#{self.agencia}#{self.conta_corrente}".modulo10
      end

      # Segunda parte do código de barras.
      #
      # Montagem é baseada no tipo de carteira, com registro e sem registro(57)
      #
      # @return [String] 25 caracteres numéricos.
      def codigo_barras_segunda_parte
        case self.carteira.to_i
          when 57
            "#{self.agencia}#{self.conta_corrente}#{self.agencia_conta_corrente_nosso_numero_dv}#{self.numero_documento}"
          else
            # TODO verificar com o banco, pois não consta na documentação
            "000000#{self.agencia}#{self.conta_corrente}#{self.agencia_conta_corrente_nosso_numero_dv}#{self.numero_documento}"
        end
      end
    end
  end
end