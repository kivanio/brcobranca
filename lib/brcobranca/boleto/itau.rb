# -*- encoding: utf-8 -*-
module Brcobranca
  module Boleto
    class Itau < Base # Banco Itaú

      # Usado somente em carteiras especiais com registro para complementar o número do cocumento
      attr_reader :seu_numero

      validates_length_of :agencia, :maximum => 4, :message => 'deve ser menor ou igual a 4 dígitos.'
      validates_length_of :convenio, :maximum => 5, :message => 'deve ser menor ou igual a 5 dígitos.'
      validates_length_of :numero_documento, :maximum => 8, :message => 'deve ser menor ou igual a 8 dígitos.'
      validates_length_of :conta_corrente, :maximum => 5, :message => 'deve ser menor ou igual a 5 dígitos.'
      validates_length_of :seu_numero, :maximum => 7, :message => 'deve ser menor ou igual a 7 dígitos.'

      # Nova instancia do Itau
      # @param (see Brcobranca::Boleto::Base#initialize)
      def initialize(campos={})
        campos = {:carteira => '175'}.merge!(campos)
        super(campos)
      end

      # Codigo do banco emissor (3 dígitos sempre)
      #
      # @return [String] 3 caracteres numéricos.
      def banco
        '341'
      end

      # Número do convênio/contrato do cliente junto ao banco.
      # @return [String] 5 caracteres numéricos.
      def convenio=(valor)
        @convenio = valor.to_s.rjust(5, '0') if valor
      end

      # Conta corrente
      # @return [String] 5 caracteres numéricos.
      def conta_corrente=(valor)
        @conta_corrente = valor.to_s.rjust(5, '0') if valor
      end

      # Número seqüencial utilizado para identificar o boleto.
      # @return [String] 8 caracteres numéricos.
      def numero_documento=(valor)
        @numero_documento = valor.to_s.rjust(8, '0') if valor
      end

      # Número seqüencial utilizado para identificar o boleto.
      # @return [String] 7 caracteres numéricos.
      def seu_numero=(valor)
        @seu_numero = valor.to_s.rjust(7, '0') if valor
      end

      # Dígito verificador do nosso número.
      #
      # Para a grande maioria das carteiras, são considerados para a obtenção do DAC/DV, os dados
      # "AGENCIA(sem DAC/DV)/CONTA(sem DAC/DV)/CARTEIRA/NOSSO NUMERO", calculado pelo criterio do Modulo 10.<br/>
      # A excecao, estão as carteiras 112, 126, 131, 146, 150 e 168 cuja obtenção esta baseada apenas nos
      # dados "CARTEIRA/NOSSO NUMERO".
      #
      # @return [String] 1 caracteres numéricos.
      def nosso_numero_dv
        if %w(112 126 131 146 150 168).include?(self.carteira)
          "#{self.carteira}#{self.numero_documento}".modulo10
        else
          "#{self.agencia}#{self.conta_corrente}#{self.carteira}#{self.numero_documento}".modulo10
        end
      end

      # Calcula o dígito verificador para conta corrente do Itau.
      # Retorna apenas o dígito verificador da conta ou nil caso seja impossível calcular.
      def agencia_conta_corrente_dv
        "#{self.agencia}#{self.conta_corrente}".modulo10
      end

      # Nosso número para exibir no boleto.
      # @return [String]
      # @example
      #  boleto.nosso_numero_boleto #=> "175/12345678-4"
      def nosso_numero_boleto
        "#{self.carteira}/#{self.numero_documento}-#{self.nosso_numero_dv}"
      end

      # Agência + conta corrente do cliente para exibir no boleto.
      # @return [String]
      # @example
      #  boleto.agencia_conta_boleto #=> "0811 / 53678-8"
      def agencia_conta_boleto
        "#{self.agencia} / #{self.conta_corrente}-#{self.agencia_conta_corrente_dv}"
      end

      # Segunda parte do código de barras.
      #
      # CARTEIRAS 198, 106, 107,122, 142, 143, 195 e 196<br/>
      # 01 a 03 | 03 | 9(3) | Código do Banco na Câmara de Compensação = ‘341’<br/>
      # 04 a 04 | 01 | 9(1) | Código da Moeda = '9'<br/>
      # 05 a 05 | 01 | 9(1) | DAC do Código de Barras MOD 11-2a9<br/>
      # 06 a 09 | 04 | 9(04) | Fator de Vencimento<br/>
      # 10 a 19 | 10 | 9(08) | V(2) Valor<br/>
      # 20 a 22 | 03 | 9(3) | Carteira<br/>
      # 23 a 30 | 08 | 9(8) | Nosso Número<br/>
      # 31 a 37 | 07 | 9(7) | Seu Número (Número do Documento)<br/>
      # 38 a 42 | 05 | 9(5) | Código do Cliente (fornecido pelo Banco)<br/>
      # 43 a 43 | 01 | 9(1) | DAC dos campos acima (posições 20 a 42) MOD 10<br/>
      # 44 a 44 | 01 | 9(1) | Zero<br/>
      #
      # DEMAIS CARTEIRAS<br/>
      # 01 a 03 | 03 | 9(03) | Código do Banco na Câmara de Compensação = '341'<br/>
      # 04 a 04 | 01 | 9(01) | Código da Moeda = '9'<br/>
      # 05 a 05 | 01 | 9(01) | DAC código de Barras MOD 11-2a9<br/>
      # 06 a 09 | 04 | 9(04) | Fator de Vencimento<br/>
      # 10 a 19 | 10 | 9(08)V(2) | Valor<br/>
      # 20 a 22 | 03 | 9(03) | Carteira<br/>
      # 23 a 30 | 08 | 9(08) | Nosso Número<br/>
      # 31 a 31 | 01 | 9(01) | DAC [Agência /Conta/Carteira/Nosso Número] MOD 10<br/>
      # 32 a 35 | 04 | 9(04) | N.º da Agência cedente<br/>
      # 36 a 40 | 05 | 9(05) | N.º da Conta Corrente<br/>
      # 41 a 41 | 01 | 9(01) | DAC [Agência/Conta Corrente] MOD 10<br/>
      # 42 a 44 | 03 | 9(03) | Zeros<br/>
      #
      # @return [String] 25 caracteres numéricos.
      def codigo_barras_segunda_parte
        case self.carteira.to_i
          when 198, 106, 107, 122, 142, 143, 195, 196
            dv = "#{self.carteira}#{numero_documento}#{self.seu_numero}#{self.convenio}".modulo10
            "#{self.carteira}#{self.numero_documento}#{self.seu_numero}#{self.convenio}#{dv}0"
          else
            "#{self.carteira}#{self.numero_documento}#{self.nosso_numero_dv}#{self.agencia}#{self.conta_corrente}#{self.agencia_conta_corrente_dv}000"
        end
      end

    end
  end
end