# -*- encoding: utf-8 -*-
module Brcobranca
  module Boleto
    class Unibanco < Base # Banco UNIBANCO

      #  Com Registro 4
      #  Sem Registro 5
      validates_inclusion_of :carteira, :in => %w( 5 4 ), :message => "não existente para este banco."
      validates_length_of :agencia, :maximum => 4, :message => "deve ser menor ou igual a 4 dígitos."
      validates_length_of :convenio, :maximum => 7, :message => "deve ser menor ou igual a 7 dígitos."
      validates_length_of :conta_corrente, :maximum => 7, :message => "deve ser menor ou igual a 7 dígitos."

      validates_each :numero_documento do |record, attr, value|
        record.errors.add attr, 'deve ser menor ou igual a 14 dígitos.' if (value.to_s.size > 14) && (record.carteira.to_i == 5)
        record.errors.add attr, 'deve ser menor ou igual a 11 dígitos.' if (value.to_s.size > 11) && (record.carteira.to_i == 4)
      end

      # Nova instancia do Unibanco
      # @param (see Brcobranca::Boleto::Base#initialize)
      def initialize(campos={})
        campos = {:carteira => "5"}.merge!(campos)
        super(campos)
      end

      # Codigo do banco emissor (3 dígitos sempre)
      def banco
        "409"
      end

      # Número do convênio/contrato do cliente junto ao banco emissor formatado com 7 dígitos
      def convenio=(valor)
        @convenio = valor.to_s.rjust(7,'0') unless valor.nil?
      end

      # Número seqüencial utilizado para identificar o boleto (Número de dígitos depende do tipo de carteira).
      def numero_documento
        case self.carteira.to_i
        when 5
          @numero_documento.to_s.rjust(14,'0')
        when 4
          @numero_documento.to_s.rjust(11,'0')
        else
          raise(ArgumentError, "Tipo de carteira não implementado")
        end
      end

      def nosso_numero_dv
        self.numero_documento.modulo11_2to9
      end

      # Campo usado apenas na exibição no boleto
      def nosso_numero_boleto
        "#{self.numero_documento}-#{self.nosso_numero_dv}"
      end

      # Campo usado apenas na exibição no boleto
      def agencia_conta_boleto
        "#{self.agencia} / #{self.conta_corrente}-#{self.conta_corrente_dv}"
      end

      # Responsável por montar uma String com 43 caracteres que será usado na criação do código de barras
      #
      # Cobrança sem registro (CÓDIGO DE BARRAS)
      # Posição Tamanho Descrição
      # 1 a 3 3 número de identificação do Unibanco: 409 (número FIXO)
      # 4 1 código da moeda. Real (R$)=9 (número FIXO)
      # 5 1 dígito verificador do CÓDIGO DE BARRAS
      # 6 a 9 4 fator de vencimento
      # 10 a 19 10  valor do título com zeros à esquerda
      # 20  1 código para transação CVT: 5 (número FIXO)(5=7744-5)
      # 21 a 27 7 número do cliente no CÓDIGO DE BARRAS + dígito verificador
      # 28 a 29 2 vago. Usar 00 (número FIXO)
      # 30 a 43 14  Número de referência do cliente
      # 44  1 Dígito verificador
      #
      # Cobrança com registro (CÓDIGO DE BARRAS)
      # Posição  Tamanho Descrição
      # 1 a 3  3 Número de identificação do Unibanco: 409 (número FIXO)
      # 4  1 Código da moeda. Real (R$)=9 (número FIXO)
      # 5  1 dígito verificador do CÓDIGO DE BARRAS
      # 6 a 9  4 fator de vencimento em 4 algarismos, conforme tabela da página 14
      # 10 a 19  10  valor do título com zeros à esquerda
      # 20 a 21  2 Código para transação CVT: 04 (número FIXO) (04=5539-5)
      # 22 a 27  6 data de vencimento (AAMMDD)
      # 28 a 32  5 Código da agência + dígito verificador
      # 33 a 43  11  “Nosso Número” (NNNNNNNNNNN)
      # 44 1 Super dígito do “Nosso Número” (calculado com o MÓDULO 11 (de 2 a 9))
      def codigo_barras_segunda_parte
        case self.carteira.to_i
        when 5
          "#{self.carteira}#{self.convenio}00#{self.numero_documento}#{self.nosso_numero_dv}"
        else # 4
          data = self.data_vencimento.strftime('%y%m%d')
          "0#{self.carteira}#{data}#{self.agencia}#{self.agencia_dv}#{self.numero_documento}#{self.nosso_numero_dv}"
        end
      end
    end
  end
end