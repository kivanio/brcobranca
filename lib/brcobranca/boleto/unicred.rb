# -*- encoding: utf-8 -*-
#
module Brcobranca
  module Boleto
    class Unicred < Base # Banco Unicred
      # <b>REQUERIDO</b>: Código do posto da cooperativa de crédito
      attr_accessor :posto

      # <b>REQUERIDO</b>: Byte de identificação do cedente do bloqueto utilizado para compor o nosso número.
      attr_accessor :byte_idt

      validates_length_of :agencia, maximum: 4, message: 'deve ser menor ou igual a 4 dígitos.'
      validates_length_of :nosso_numero, maximum: 5, message: 'deve ser menor ou igual a 5 dígitos.'
      validates_length_of :conta_corrente, maximum: 5, message: 'deve ser menor ou igual a 5 dígitos.'
      # Carteira
      # 1 – Com Registro
      # 3 – Sem Registro
      # Obs.: O Unicred não validará este campo.
      validates_length_of :carteira, maximum: 1, message: 'deve ser menor ou igual a 1 dígitos.'
      validates_length_of :posto, maximum: 2, message: 'deve ser menor ou igual a 2 dígitos.'
      validates_length_of :byte_idt, is: 1, message: 'deve ser 1 se o numero foi gerado pela agencia ou 2-9 se foi gerado pelo beneficiário'
      validates_length_of :convenio, maximum: 5, message: 'deve ser menor ou igual a 5 dígitos.'

      # Nova instancia do Unicred
      # @param (see Brcobranca::Boleto::Base#initialize)
      def initialize(campos = {})
        campos = { carteira: '3',
          especie_documento: 'DM',
          local_pagamento: 'PAGÁVEL PREFERENCIALMENTE NAS AGÊNCIAS DA UNICRED'
        }.merge!(campos)
        super(campos)
      end

      # Codigo do banco emissor (3 dígitos sempre)
      #
      # @return [String] 3 caracteres numéricos.
      def banco
        '748'
      end

      # Carteira
      #
      # @return [String] 2 caracteres numéricos.
      def carteira=(valor)
        @carteira = valor.to_s.rjust(1, '0') if valor
      end

      # Posto
      #
      # @return [String] 2 caracteres numéricos.
      def posto=(valor)
        @posto = valor.to_s.rjust(2, '0') if valor
      end

      # Número da conta corrente
      # @return [String] 5 caracteres numéricos.
      def conta_corrente=(valor)
        @conta_corrente = valor.to_s.rjust(5, '0') if valor
      end

      # Código Beneficiário
      # @return [String] 5 caracteres numéricos.
      def convenio=(valor)
        @convenio = valor.to_s.rjust(5, '0') if valor
      end

      # Dígito verificador do banco
      # @return [String] 1 caractere.
      def banco_dv
        'X'
      end

      # Nosso número para exibir no boleto.
      # O campo Nosso Número deve ser apresentado no formato AA/BXXXXX-D, onde:
      # AA = Ano atual
      # B = Byte que pode ser de 2 a 9. Somente será 1 se forem boletos pré-impressos.
      # XXXXX = número sequencial
      # D = dígito verificador calculado
      # @return [String]
      # @example
      #  boleto.nosso_numero_boleto #=> "14/200022-5"
      def nosso_numero_boleto
        "#{nosso_numero_with_byte_idt[0..1]}/#{nosso_numero_with_byte_idt[2..-1]}-#{nosso_numero_dv}"
      end

      def nosso_numero_codigo_barra
        nosso_numero_boleto.gsub(/\D/, '')
      end

      def nosso_numero_with_byte_idt
        "#{data_processamento.strftime('%y')}#{byte_idt}#{nosso_numero}"
      end

      # Número seqüencial utilizado para identificar o boleto.
      # @return [String] 5 caracteres numéricos.
      def nosso_numero=(valor)
        @nosso_numero = valor.to_s.rjust(5, '0') if valor
      end

      # Dígito verificador do nosso número
      # @return [Integer] 1 caracteres numéricos.
      def nosso_numero_dv
        "#{agencia_posto_conta}#{nosso_numero_with_byte_idt}"
          .modulo11(mapeamento: mapeamento_para_modulo_11)
      end

      def agencia_conta_boleto
        "#{agencia}.#{posto}.#{convenio}"
      end

      def agencia_posto_conta
        "#{agencia}#{posto}#{convenio}"
      end

      # Segunda parte do código de barras.
      # Posição       Tamanho      Conteúdo
      # 20 – 20       01      Código numérico correspondente ao tipo de cobrança: “1” – Com Registro “3 – Sem Registro”. Obs.: O SICREDI não validará este campo.
      # 21 – 21       01      Código numérico correspondente ao tipo de carteira: “1” - carteira simples
      # 22 – 30       09      Nosso número
      # 31 – 34      # 04      # Cooperativa de crédito/agência beneficiária
      # 35 – 36      # 02      # Posto da cooperativa de crédito/agência beneficiária
      # 37 – 41      # 05      # Código do beneficiário
      # 42 – 42      # 01      # Será 1 (um) quando houver valor expresso no campo “valor do documento”
      # 43 – 43      # 01      # Filler – zeros “0”
      # 44 – 44      # 01      # DV do campo livre calculado por módulo 11 com aproveitamento total (resto igual a 0 ou 1 DV cai para 0)
      def codigo_barras_segunda_parte
        campo_livre = "#{carteira}1#{nosso_numero_codigo_barra}#{agencia_posto_conta}10"
        campo_livre + campo_livre.modulo11(mapeamento: mapeamento_para_modulo_11).to_s
      end

      private

      def mapeamento_para_modulo_11
        {
          10 => 0,
          11 => 0
        }
      end
    end
  end
end
