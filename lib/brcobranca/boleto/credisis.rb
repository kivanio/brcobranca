# -*- encoding: utf-8 -*-
module Brcobranca
  module Boleto
    class Credisis < Base # CrediSIS
      validates_length_of :agencia, maximum: 4, message: 'deve ser menor ou igual a 4 dígitos.'
      validates_length_of :conta_corrente, maximum: 7, message: 'deve ser menor ou igual a 7 dígitos.'
      validates_length_of :carteira, is: 2, message: 'deve ser menor ou igual a 2 dígitos.'
      validates_length_of :convenio, is: 6, message: 'deve ser menor ou igual a 6 dígitos.'
      validates_length_of :nosso_numero, maximum: 6, message: 'deve ser menor ou igual a 6 dígitos.'
      validates_presence_of :documento_cedente, message: 'não pode estar em branco.'
      validates_numericality_of :documento_cedente, message: 'não é um número.'

      # Nova instancia do CrediSIS
      # @param (see Brcobranca::Boleto::Base#initialize)
      def initialize(campos = {})
        campos = { carteira: '18' }.merge!(campos)
        super(campos)
      end

      # Codigo do banco emissor (3 dígitos sempre)
      #
      # @return [String] 3 caracteres numéricos.
      def banco
        '097'
      end

      # Carteira
      # @return [String] 2 caracteres numéricos.
      def carteira=(valor)
        @carteira = valor.to_s.rjust(2, '0') if valor
      end

      # Dígito verificador do banco
      #
      # @return [String] 1 caracteres numéricos.
      def banco_dv
        '3'
      end

      # Retorna dígito verificador da agência
      #
      # @return [String] 1 caracteres numéricos.
      def agencia_dv
        agencia.modulo11(mapeamento: { 10 => 'X' })
      end

      # Conta corrente
      # @return [String] 7 caracteres numéricos.
      def conta_corrente=(valor)
        @conta_corrente = valor.to_s.rjust(7, '0') if valor
      end

      # Número do convênio/contrato do cliente junto ao banco.
      # @return [String] 6 caracteres numéricos.
      def convenio=(valor)
        @convenio = valor.to_s.rjust(6, '0') if valor
      end

      # Dígito verificador da conta corrente
      # @return [String] 1 caracteres numéricos.
      def conta_corrente_dv
        conta_corrente.modulo11(mapeamento: { 10 => 'X' })
      end

      # Nosso número
      # @return [String] 6 caracteres numéricos.
      def nosso_numero=(valor)
        @nosso_numero = valor.to_s.rjust(6, '0')
      end

      # Nosso número para exibir no boleto.
      # @return [String]
      # @example
      #  boleto.nosso_numero_boleto #=> "10000000027000095-7"
      def nosso_numero_boleto
        "097#{documento_cedente_dv}#{agencia}#{convenio}#{nosso_numero}"
      end

      # Agência + conta corrente do cliente para exibir no boleto.
      # @return [String]
      # @example
      #  boleto.agencia_conta_boleto #=> "0001-9 / 0000002-7"
      def agencia_conta_boleto
        "#{agencia}-#{agencia_dv} / #{conta_corrente}-#{conta_corrente_dv}"
      end

      #X – Módulo 11 do CPF/CNPJ (incluindo dígitos verificadores) do Beneficiário emissor
      # Obs.: Caso for CPF, utilizar 9 como limitador da multiplicação.
      # Caso for CNPJ, utilizar 8 no limitador da multiplicação.
      def documento_cedente_dv
        options = { mapeamento: { 0 => 1, 10 => 1, 11 => 1 } }
        options.merge(multiplicador: [8, 7, 6, 5, 4, 3, 2]) if documento_cedente.to_s.size > 11
        documento_cedente.modulo11(options)
      end

      # Segunda parte do código de barras.
      # @return [String] 25 caracteres numéricos.
      #1. - Número do Banco: “097”
      # 2. - Moeda: “9”
      # 3. - DV do Código de Barras, Baseado no Módulo 11 (Vide Anexo X).
      # 4. - Fator de Vencimento do Boleto (Vide Anexo VII).
      # 5. - Valor do Título, expresso em Reais, com 02 casas decimais.
      # 6. - Fixo Zeros: Campo com preenchimento Zerado “00000”
      # 7. - Composição do Nosso Número: 097XAAAACCCCCCSSSSSS, sendo:
      #      Composição do Nosso Número
      #      097    - Fixo
      #      X      - Módulo 11 do CPF/CNPJ (Incluindo dígitos verificadores) do Beneficiário.
      #      AAAA   - Código da Agência CrediSIS ao qual o Beneficiário possui Conta.
      #      CCCCCC - Código de Convênio do Beneficiário no Sistema CrediSIS
      #      SSSSSS - Sequencial Único do Boleto
      def codigo_barras_segunda_parte
        "00000097#{documento_cedente_dv}#{agencia}#{convenio}#{nosso_numero}"
      end
    end
  end
end
