# -*- encoding: utf-8 -*-
# @author Kivanio Barbosa
# @author Ronaldo Araujo
module Brcobranca
  module Boleto
    class Santander < Base # Banco Santander
      # Usado somente em carteiras especiais com registro para complementar o número do documento
      attr_reader :seu_numero

      validates_length_of :agencia, maximum: 4, message: 'deve ser menor ou igual a 4 dígitos.'
      validates_length_of :convenio, maximum: 7, message: 'deve ser menor ou igual a 7 dígitos.'
      validates_length_of :numero_documento, maximum: 8, message: 'deve ser menor ou igual a 8 dígitos.'
      validates_length_of :seu_numero, maximum: 7, message: 'deve ser menor ou igual a 7 dígitos.'

      # Nova instancia do Santander
      # @param (see Brcobranca::Boleto::Base#initialize)
      def initialize(campos = {})
        campos = { carteira: '102' }.merge!(campos)
        super(campos)
      end

      # Codigo do banco emissor (3 dígitos sempre)
      #
      # @return [String] 3 caracteres numéricos.
      def banco
        '033'
      end

      # Número da conta corrente
      # @return [String] 9 caracteres numéricos.
      def conta_corrente=(valor)
        @conta_corrente = valor.to_s.rjust(9, '0') if valor
      end

      # Número do convênio/contrato do cliente junto ao banco. No Santander, é
      # chamado de Código do Cedente.
      # @return [String] 7 caracteres numéricos.
      def convenio=(valor)
        @convenio = valor.to_s.rjust(7, '0') if valor
      end

      # Número sequencial utilizado para identificar o boleto.
      # @return [String] 8 caracteres numéricos.
      def numero_documento=(valor)
        @numero_documento = valor.to_s.rjust(8, '0') if valor
      end

      # Número sequencial utilizado para identificar o boleto.
      # @return [String] 7 caracteres numéricos.
      def seu_numero=(valor)
        @seu_numero = valor.to_s.rjust(7, '0') if valor
      end

      # Dígito verificador do nosso número.
      # @return [String] 1 caracteres numéricos.
      def nosso_numero_dv
        nosso_numero = numero_documento.to_s.rjust(12, '0') unless numero_documento.nil?
        nosso_numero.modulo11(
          multiplicador: (2..9).to_a,
          mapeamento: {10 => 0, 11 => 0}
        ) { |total| 11 - (total % 11) }
      end

      # Nosso número para exibir no boleto.
      # @return [String]
      # @example
      #  boleto.nosso_numero_boleto #=> "000090002720-7"
      def nosso_numero_boleto
        nosso_numero = numero_documento.to_s.rjust(12, '0') unless numero_documento.nil?
        "#{nosso_numero}-#{nosso_numero_dv}"
      end

      # Agência + codigo do cedente do cliente para exibir no boleto.
      # @return [String]
      # @example
      #  boleto.agencia_conta_boleto #=> "0059/1899775"
      def agencia_conta_boleto
        "#{agencia}/#{convenio}"
      end

      # Segunda parte do código de barras.
      # 9(01) | Fixo 9 <br/>
      # 9(07) | Convenio <br/>
      # 9(05) | Fixo 00000<br/>
      # 9(08) | Nosso Numero<br/>
      # 9(01) | IOF<br/>
      # 9(03) | Carteira de cobrança<br/>
      #
      # @return [String] 25 caracteres numéricos.
      def codigo_barras_segunda_parte
        "9#{convenio}0000#{numero_documento}#{nosso_numero_dv}0#{carteira}"
      end
    end
  end
end
