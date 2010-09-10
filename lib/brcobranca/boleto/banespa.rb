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
      def banco
        "033"
      end

      # Retorna código da agencia formatado com zeros a esquerda.
      def agencia=(valor)
        @agencia = valor.to_s.rjust(3,'0') unless valor.nil?
      end

      # Número do convênio/contrato do cliente junto ao banco emissor formatado com 11 dígitos
      def convenio=(valor)
        @convenio = valor.to_s.rjust(11,'0') unless valor.nil?
      end

      # Número seqüencial de 7 dígitos utilizado para identificar o boleto.
      def numero_documento=(valor)
        @numero_documento = valor.to_s.rjust(7,'0') unless valor.nil?
      end

      # Número sequencial utilizado para distinguir os boletos na agência.
      def nosso_numero
        "#{self.agencia}#{self.numero_documento}"
      end

      # Retorna dígito verificador do nosso número calculado como contas na documentação.
      def nosso_numero_dv
        self.nosso_numero.modulo_10_banespa
      end

      # Retorna nosso numero pronto para exibir no boleto.
      def nosso_numero_boleto
        "#{self.nosso_numero.gsub(/^(.{3})(.{7})$/,'\1 \2')} #{self.nosso_numero_dv}"
      end

      def agencia_conta_boleto
        self.convenio.gsub(/^(.{3})(.{2})(.{5})(.{1})$/,'\1 \2 \3 \4')
      end

      # Responsável por montar uma String com 43 caracteres que será usado na criação do código de barras.
      def codigo_barras_segunda_parte
        self.campo_livre_com_dv1_e_dv2
      end

      # CAMPO LIVRE
      #    Código do cedente                                                                            PIC  9  (011)
      #    Nosso número                                                                                 PIC  9  (007)
      #    Filler                                                                                       PIC  9  (002)   = 00
      #    Código do banco cedente                                                                      PIC  9  (003)   = 033
      #    Dígito verificador 1                                                                         PIC  9  (001)
      #    Dígito verificador 2                                                                         PIC  9  (001)
      def campo_livre
        "#{self.convenio}#{self.numero_documento}00#{self.banco}"
      end

      #campo livre com os digitos verificadores como consta na documentação do banco.
      def campo_livre_com_dv1_e_dv2
        dv1 = self.campo_livre.modulo10 #dv 1 inicial
        dv2 = nil

        begin
          recalcular_dv2 = false
          valor_inicial = "#{self.campo_livre}#{dv1}"
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

        return "#{self.campo_livre}#{dv1}#{dv2}"
      end

    end
  end
end