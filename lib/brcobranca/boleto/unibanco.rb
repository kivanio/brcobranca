# -*- encoding: utf-8 -*-
module Brcobranca
  module Boleto
    class Unibanco < Base # Banco UNIBANCO

      #  Com Registro 4
      #  Sem Registro 5
      validates_inclusion_of :carteira, :in => %w( 5 4 ), :message => 'não existente para este banco.'
      validates_length_of :agencia, :maximum => 4, :message => 'deve ser menor ou igual a 4 dígitos.'
      validates_length_of :convenio, :maximum => 7, :message => 'deve ser menor ou igual a 7 dígitos.'
      validates_length_of :conta_corrente, :maximum => 7, :message => 'deve ser menor ou igual a 7 dígitos.'

      validates_each :numero_documento do |record, attr, value|
        record.errors.add attr, 'deve ser menor ou igual a 14 dígitos.' if (value.to_s.size > 14) && (record.carteira.to_i == 5)
        record.errors.add attr, 'deve ser menor ou igual a 11 dígitos.' if (value.to_s.size > 11) && (record.carteira.to_i == 4)
      end

      # Nova instancia do Unibanco
      # @param (see Brcobranca::Boleto::Base#initialize)
      def initialize(campos={})
        campos = {:carteira => '5'}.merge!(campos)
        super(campos)
      end

      # Codigo do banco emissor (3 dígitos sempre)
      #
      # @return [String] 3 caracteres numéricos.
      def banco
        '409'
      end

      # Número do convênio/contrato do cliente junto ao banco.
      # @return [String] 7 caracteres numéricos.
      def convenio=(valor)
        @convenio = valor.to_s.rjust(7, '0') if valor
      end

      # Número seqüencial utilizado para identificar o boleto.
      #
      # Carteira 5 = 14 caracteres numéricos.<br/>
      # Carteira 4 = 11 caracteres numéricos.
      #
      # @return [String]
      def numero_documento
        case self.carteira.to_i
          when 5
            @numero_documento.to_s.rjust(14, '0')
          else #4
            @numero_documento.to_s.rjust(11, '0')
        end
      end

      # Dígito verificador do nosso número.
      # @return [String] 1 caracteres numéricos.
      def nosso_numero_dv
        self.numero_documento.modulo11_2to9
      end

      # Nosso número para exibir no boleto.
      # @return [String]
      # @example
      #  boleto.nosso_numero_boleto #=> "00085068014982-9"
      def nosso_numero_boleto
        "#{self.numero_documento}-#{self.nosso_numero_dv}"
      end

      # Número do convênio/contrato do cliente para exibir no boleto.
      # @return [String]
      # @example
      #  boleto.agencia_conta_boleto #=> "0123 / 0100618-5"
      def agencia_conta_boleto
        "#{self.agencia} / #{self.conta_corrente}-#{self.conta_corrente_dv}"
      end

      # Segunda parte do código de barras.
      #
      # Cobrança sem registro (CÓDIGO DE BARRAS)<br/>
      # Posição | Tamanho | Descrição<br/>
      # 1 a 3 | 3 | número de identificação do Unibanco: 409 (número FIXO)<br/>
      # 4 | 1 | código da moeda. Real (R$)=9 (número FIXO)<br/>
      # 5 | 1 | dígito verificador do CÓDIGO DE BARRAS<br/>
      # 6 a 9 | 4 | fator de vencimento<br/>
      # 10 a 19 | 10 |  valor do título com zeros à esquerda<br/>
      # 20 |  1 | código para transação CVT: 5 (número FIXO)(5=7744-5)<br/>
      # 21 a 27 | 7 | número do cliente no CÓDIGO DE BARRAS + dígito verificador<br/>
      # 28 a 29 | 2 | vago. Usar 00 (número FIXO)<br/>
      # 30 a 43 | 14 |  Número de referência do cliente<br/>
      # 44 |  1 | Dígito verificador<br/>
      #
      # Cobrança com registro (CÓDIGO DE BARRAS)<br/>
      # Posição |  Tamanho | Descrição<br/>
      # 1 a 3 |  3 | Número de identificação do Unibanco: 409 (número FIXO)<br/>
      # 4 |  1 | Código da moeda. Real (R$)=9 (número FIXO)<br/>
      # 5 |  1 | dígito verificador do CÓDIGO DE BARRAS<br/>
      # 6 a 9 |  4 | fator de vencimento em 4 algarismos, conforme tabela da página 14<br/>
      # 10 a 19 |  10 |  valor do título com zeros à esquerda<br/>
      # 20 a 21 |  2 | Código para transação CVT: 04 (número FIXO) (04=5539-5)<br/>
      # 22 a 27 |  6 | data de vencimento (AAMMDD)<br/>
      # 28 a 32 |  5 | Código da agência + dígito verificador<br/>
      # 33 a 43 |  11 |  “Nosso Número” (NNNNNNNNNNN)<br/>
      # 44 | 1 Super dígito do “Nosso Número” (calculado com o MÓDULO 11 (de 2 a 9))<br/>
      #
      # @return [String] 25 caracteres numéricos.
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