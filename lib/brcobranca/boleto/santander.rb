# -*- encoding: utf-8 -*-
# @author Kivanio Barbosa
# @author Ronaldo Araujo
module Brcobranca
  module Boleto
    class Santander < Base # Banco Santander

      # Usado somente em carteiras especiais com registro para complementar o número do documento
      attr_reader :seu_numero

      validates_length_of :agencia, :maximum => 4, :message => 'deve ser menor ou igual a 4 dígitos.'
      validates_length_of :convenio, :maximum => 7, :message => 'deve ser menor ou igual a 7 dígitos.'
      validates_length_of :numero_documento, :maximum => 8, :message => 'deve ser menor ou igual a 8 dígitos.'
      validates_length_of :seu_numero, :maximum => 7, :message => 'deve ser menor ou igual a 7 dígitos.'

      # Nova instancia do Santander
      # @param (see Brcobranca::Boleto::Base#initialize)
      def initialize(campos={})
        campos = {:carteira => '102',
                  :conta_corrente => '00000' # Obrigatória na classe base
        }.merge!(campos)
        super(campos)
      end

      # Codigo do banco emissor (3 dígitos sempre)
      #
      # @return [String] 3 caracteres numéricos.
      def banco
        '033'
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
        nosso_numero = self.numero_documento.to_s.rjust(12, '0') unless self.numero_documento.nil?
        nosso_numero.modulo11_2to9
      end

      # Nosso número para exibir no boleto.
      # @return [String]
      # @example
      #  boleto.nosso_numero_boleto #=> "000090002720-7"
      def nosso_numero_boleto
        nosso_numero = self.numero_documento.to_s.rjust(12, '0') unless self.numero_documento.nil?
        "#{nosso_numero}-#{self.nosso_numero_dv}"
      end

      # Agência + codigo do cedente do cliente para exibir no boleto.
      # @return [String]
      # @example
      #  boleto.agencia_conta_boleto #=> "0059/1899775"
      def agencia_conta_boleto
        "#{self.agencia}/#{self.convenio}"
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
        "9#{self.convenio}00000#{self.numero_documento}0#{self.carteira}"
      end

    end
  end
end