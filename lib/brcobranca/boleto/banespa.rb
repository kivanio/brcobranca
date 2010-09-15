# -*- encoding: utf-8 -*-
module Brcobranca
  module Boleto
    class Banespa < Base # Banco BANESPA

      validates_length_of :agencia, :maximum => 3, :message => "deve ser menor ou igual a 3 dígitos."
      validates_length_of :convenio, :maximum => 11, :message => "deve ser menor ou igual a 11 dígitos."
      validates_length_of :numero_documento, :maximum => 7, :message => "deve ser menor ou igual a 7 dígitos."

      # Nova instancia do Banespa
      # @param (see Brcobranca::Boleto::Base#initialize)
      def initialize(campos={})
        campos = {:carteira => "COB"}.merge!(campos)
        super(campos)
      end

      # Codigo do banco emissor (3 dígitos sempre)
      #
      # @return [String] 3 caracteres numéricos.
      def banco
        "033"
      end

      # Código da agência
      # @return [String] 3 caracteres numéricos.
      def agencia=(valor)
        @agencia = valor.to_s.rjust(3,'0') unless valor.nil?
      end

      # Número do convênio/contrato do cliente junto ao banco.
      # @return [String] 11 caracteres numéricos.
      def convenio=(valor)
        @convenio = valor.to_s.rjust(11,'0') unless valor.nil?
      end

      # Número seqüencial utilizado para identificar o boleto.
      # @return [String] 7 caracteres numéricos.
      def numero_documento=(valor)
        @numero_documento = valor.to_s.rjust(7,'0') unless valor.nil?
      end

      # Agência + Número sequencial.
      # @return [String] 10 caracteres numéricos.
      def nosso_numero
        "#{self.agencia}#{self.numero_documento}"
      end

      # Dígito verificador do nosso número.
      # @return [String] 1 caracteres numéricos.
      def nosso_numero_dv
        self.nosso_numero.modulo_10_banespa
      end

      # Nosso número para exibir no boleto.
      # @return [String]
      # @example
      #  boleto.nosso_numero_boleto #=> "400 0403005 6"
      def nosso_numero_boleto
        "#{self.nosso_numero.gsub(/^(.{3})(.{7})$/,'\1 \2')} #{self.nosso_numero_dv}"
      end

      # Número do convênio/contrato do cliente para exibir no boleto.
      # @return [String]
      # @example
      #  boleto.agencia_conta_boleto #=> "000 12 38798 9"
      def agencia_conta_boleto
        self.convenio.gsub(/^(.{3})(.{2})(.{5})(.{1})$/,'\1 \2 \3 \4')
      end

      # Segunda parte do código de barras.
      #
      # Código do cedente                           |  (011)<br/>
      # Nosso número                                |  (007)<br/>
      # Filler                                      |  (002) = 00<br/>
      # Código do banco cedente                     |  (003) = 033<br/>
      # Dígito verificador 1                        |  (001)<br/>
      # Dígito verificador 2                        |  (001)<br/>
      #
      # @return [String] 25 caracteres numéricos.
      def codigo_barras_segunda_parte
        dv1 = campo_livre.modulo10 #dv 1 inicial
        dv2 = nil

        begin
          recalcular_dv2 = false
          valor_inicial = "#{campo_livre}#{dv1}"
          total = valor_inicial.multiplicador([2,3,4,5,6,7])

          case total % 11
          when 0 then
            dv2 = 0
          when 1 then
            if dv1 == 9
              dv1 = 0
            else
              dv1 += 1
            end
            recalcular_dv2 = true
          else
            dv2 = 11 - (total % 11)
          end
        end while(recalcular_dv2)

        return "#{campo_livre}#{dv1}#{dv2}"
      end

      private
      # Campo Livre
      #
      # Primeiros 23 caracteres numéricos da segunda parte do código de barras.<br/>
      #    Código do cedente                           |  (011)<br/>
      #    Nosso número                                |  (007)<br/>
      #    Filler                                      |  (002) = 00<br/>
      #    Código do banco cedente                     |  (003) = 033<br/>
      #
      # @return [String] 23 caracteres numéricos.
      def campo_livre
        "#{self.convenio}#{self.numero_documento}00#{self.banco}"
      end

    end
  end
end