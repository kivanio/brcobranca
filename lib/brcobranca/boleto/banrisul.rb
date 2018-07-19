# -*- encoding: utf-8 -*-
#
module Brcobranca
  module Boleto
    class Banrisul < Base # Banrisul
      # <b>REQUERIDO</b>: digito verificador do convenio
      attr_accessor :digito_convenio

      validates_length_of :agencia, maximum: 4, message: 'deve ser menor ou igual a 4 dígitos.'
      validates_length_of :conta_corrente, maximum: 8, message: 'deve ser menor ou igual a 8 dígitos.'
      validates_length_of :nosso_numero, maximum: 8, message: 'deve ser menor ou igual a 8 dígitos.'
      validates_length_of :carteira, maximum: 1, message: 'deve ser menor ou igual a 1 dígitos.'
      validates_length_of :convenio, maximum: 7, message: 'deve ser menor ou igual a 7 dígitos.'
      validates_length_of :digito_convenio, maximum: 2, message: 'deve ser menor ou igual a 2 dígitos.'

      def initialize(campos = {})
        campos = { carteira: '2' }.merge!(campos)
        super(campos)
      end

      # Codigo do banco emissor (3 dígitos sempre)
      #
      # @return [String] 3 caracteres numéricos.
      def banco
        '041'
      end

      # Dígito verificador do banco
      #
      # @return [String] 1 caractere.
      def banco_dv
        '8'
      end

      # Agência
      #
      # @return [String] 4 caracteres numéricos.
      def agencia=(valor)
        @agencia = valor.to_s.rjust(4, '0') if valor
      end

      # Conta
      #
      # @return [String] 8 caracteres numéricos.
      def conta_corrente=(valor)
        @conta_corrente = valor.to_s.rjust(8, '0') if valor
      end

      # Número documento
      #
      # @return [String] 8 caracteres numéricos.
      def nosso_numero=(valor)
        @nosso_numero = valor.to_s.rjust(8, '0') if valor
      end

      # Número do convênio do cliente junto ao banco.
      # @return [String] 7 caracteres numéricos.
      def convenio=(valor)
        @convenio = valor.to_s.rjust(7, '0') if valor
      end

      # Digito do convênio do cliente junto ao banco.
      # @return [String] 2 caracteres numéricos.
      def digito_convenio=(valor)
        @digito_convenio = valor.to_s.rjust(2, '0') if valor
      end

      # Nosso número para exibição no boleto.
      #
      # @return [String] caracteres numéricos.
      def nosso_numero_boleto
        "#{nosso_numero}-#{nosso_numero.duplo_digito}"
      end

      def agencia_conta_boleto
        "#{agencia} / #{convenio[0..5]}.#{convenio[6]}.#{digito_convenio}"
      end

      # Posições 20 a 20 - Produto:
      #                    1 Cobrança Normal, Fichário emitido pelo BANRISUL.
      #                    2 Cobrança Direta, Fichário emitido pelo CLIENTE.
      # Posição 21 a 21 - Constante 1
      # Posição 22 a 25 - Código da Agência, com quatro dígitos, sem o Número de Controle.
      # Posição 26 a 32 - Código de Cedente do Beneficiário sem Número de Controle.
      # Posição 33 a 40 - Nosso Número sem Número de Controle.
      # Posição 41 a 42 - Constante 40.
      # Posição 43 a 44 - Duplo Dígito referente às posições 20 a 42 (módulos 10 e 11).
      def codigo_barras_segunda_parte
        campo_livre = "#{carteira}1#{agencia}#{convenio}#{nosso_numero}40"
        campo_livre + campo_livre.duplo_digito
      end
    end
  end
end
