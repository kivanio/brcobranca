# -*- encoding: utf-8 -*-
#
module Brcobranca
  module Boleto
    class Citibank < Base # Citibank
      # <b>REQUERIDO</b>: Portfolio
      attr_accessor :portfolio

      validates_length_of :convenio, is: 10, message: 'deve possuir 10 dígitos.' #Conta cosmos
      validates_length_of :nosso_numero, is: 11, message: 'deve possuir 11 dígitos.'
      validates_length_of :portfolio, is: 3, message: 'deve possuir 3 dígitos.' #Portfolio

      # @param (see Brcobranca::Boleto::Base#initialize)
      def initialize(campos = {})
        campos = {
          carteira: '3',
          carteira_label: '3',
        }.merge!(campos)
        super(campos)
      end

      # Código do banco emissor
      # @return [String]
      def banco
        '745'
      end

      # @return [String]
      def banco_dv
        '5'
      end

      # Número do portfolio do cliente junto ao banco.
      # @return [String] 3 caracteres numéricos.
      def portfolio=(valor)
        @portfolio = valor.to_s.rjust(3, '0') if valor
      end

      # Número do convênio/contrato do cliente junto ao banco.
      # @return [String] 10 caracteres numéricos.
      def convenio=(valor)
        @convenio = valor.to_s.rjust(10, '0') if valor
      end

      # Número seqüencial utilizado para identificar o boleto.
      # @return [String] 11 caracteres numéricos.
      def nosso_numero=(valor)
        @nosso_numero = valor.to_s.rjust(11, '0') if valor
      end

      # Nosso número, 11 dígitos
      # @return [String]
      def nosso_numero_boleto
        "#{nosso_numero}.#{nosso_numero_dv}"
      end

      # Dígito verificador do Nosso Número
      # Utiliza-se o [-1..-1] para retornar o último caracter
      # @return [String]
      def nosso_numero_dv
        "#{nosso_numero}".modulo11(
          multiplicador: (2..9).to_a,
          mapeamento: { 10 => 0, 11 => 0 }
        ) { |total| 11 - (total % 11) }.to_s
      end

      # Número da agência/código cedente do cliente para exibir no boleto.
      # @return [String]
      # @example
      #  boleto.agencia_conta_boleto #=> "1565/100000-4"
      def agencia_conta_boleto
        "#{agencia} / #{convenio}"
      end

      # Monta a segunda parte do código de barras.
      # Descrição do Campo  | Posição | Tamanho | Campo | Conteúdo do Campo
      # Código do Produto   | 20      | 1       | 6     | 3 - Cobrança com registro / sem registro ou 4 Cobrança de seguro - sem registro
      # Portfólio           | 21 a 23 | 3       | 7     | 3 últimos dígitos do campo de identificação da empresa no CITIBANK (Posição 44 a 46 do arquivo retorno)
      # Base                | 24 a 29 | 6.      | 8.    |
      # Sequência           | 30 a 31 | 2       | 9.    |
      # Dígito Conta Cosmos | 32      | 1       | 10.   |
      # Nosso Número + DV   | 33 a 44 | 12      | 11.   |
      # A discriminação de “Índice”, “Base”, “Seqüência” e “Dígito verificador” podem ser encontrados na Conta Cosmos do cedente da seguinte forma:
      # Ex.: 0.123456.78.9 = Conta Cosmos
      # 0      - Índice
      # 123456 - Base (Posição 24 a 29)
      # 78     - Sequência (Posição 30 a 31)
      # 9      - Dígito Verificador (Posição 32
      # 
      # @return [String]
      def codigo_barras_segunda_parte
        "#{carteira}#{portfolio}#{convenio[1..-1]}#{nosso_numero}#{nosso_numero_dv}"
      end
    end
  end
end
