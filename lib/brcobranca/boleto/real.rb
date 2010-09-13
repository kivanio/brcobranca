# -*- encoding: utf-8 -*-
module Brcobranca
  module Boleto
    class Real < Base # Banco REAL

      validates_length_of :agencia, :maximum => 4, :message => "deve ser menor ou igual a 4 dígitos."
      validates_length_of :conta_corrente, :maximum => 7, :message => "deve ser menor ou igual a 7 dígitos."

      validates_each :numero_documento do |record, attr, value|
        record.errors.add attr, 'deve ser menor ou igual a 13 dígitos.' if (value.to_s.size > 13) && (record.carteira.to_i == 57)
        record.errors.add attr, 'deve ser menor ou igual a 7 dígitos.' if (value.to_s.size > 7) && (record.carteira.to_i != 57)
      end

      ## Nova instancia do Real
      # @param (see Brcobranca::Boleto::Base#initialize)
      def initialize(campos={})
        campos = {:carteira => "57"}.merge!(campos)
        super(campos)
      end

      # Codigo do banco emissor (3 dígitos sempre)
      def banco
        "356"
      end

      # Número seqüencial utilizado para identificar o boleto (Número de dígitos depende do tipo de carteira).
      #  NUMERO DO BANCO : COM 7 DIGITOS P/ COBRANCA REGISTRADA
      #                     ATE 15 DIGITOS P/ COBRANCA SEM REGISTRO
      def numero_documento
        quantidade = (self.carteira.to_i == 57) ? 13 : 7
        @numero_documento.to_s.rjust(quantidade,'0')
      end

      # Campo usado apenas na exibição no boleto
      #  Deverá ser sobreescrito para cada banco
      def nosso_numero_boleto
        "#{self.numero_documento}-#{self.nosso_numero_dv}"
      end

      # Campo usado apenas na exibição no boleto
      #  Deverá ser sobreescrito para cada banco
      def agencia_conta_boleto
        "#{self.agencia}-#{self.agencia_dv} / #{self.conta_corrente}-#{self.conta_corrente_dv}"
      end

      # CALCULO DO DIGITO:
      #  APLICA-SE OS PESOS 2,1,2,1,.... AOS ALGARISMOS DO NUMERO COMPOSTO POR:
      #  NUMERO DO BANCO : COM 7 DIGITOS P/ COBRANCA REGISTRADA
      #                     ATE 15 DIGITOS P/ COBRANCA SEM REGISTRO
      #  CODIGO DA AGENCIA: 4 DIGITOS
      #  NUMERO DA CONTA : 7 DIGITOS
      def agencia_conta_corrente_nosso_numero_dv
        "#{self.numero_documento}#{self.agencia}#{self.conta_corrente}".modulo10
      end

      # Responsável por montar uma String com 43 caracteres que será usado na criação do código de barras
      def codigo_barras_segunda_parte
        # Montagem é baseada no tipo de carteira, com registro e sem registro
        case self.carteira.to_i
          # Carteira sem registro
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