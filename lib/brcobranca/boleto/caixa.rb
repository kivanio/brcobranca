# -*- encoding: utf-8 -*-
#
#
# A Caixa tem dois padrões para a geração de boleto: SIGCB e SICOB.
# O SICOB foi substiuido pelo SIGCB que é implementado por esta classe.
# http://downloads.caixa.gov.br/_arquivos/cobranca_caixa_sigcb/manuais/CODIGO_BARRAS_SIGCB.PDF
#
module Brcobranca
  module Boleto
    class Caixa < Base # Caixa
      # <b>REQUERIDO</b>: Emissão do boleto
      attr_accessor :emissao

      # Validações
      # Modalidade/Carteira de Cobrança (1-Registrada | 2-Sem Registro)
      validates_length_of :carteira, is: 1, message: 'deve possuir 1 dígitos.'
      # Emissão do boleto (4-Beneficiário)
      validates_length_of :emissao, is: 1, message: 'deve possuir 1 dígitos.'
      validates_length_of :convenio, is: 6, message: 'deve possuir 6 dígitos.'
      validates_length_of :nosso_numero, is: 15, message: 'deve possuir 15 dígitos.'

      # Nova instância da CaixaEconomica
      # @param (see Brcobranca::Boleto::Base#initialize)
      def initialize(campos = {})
        campos = {
          carteira: '1',
          carteira_label: 'RG',
          emissao: '4'
        }.merge!(campos)

        campos[:local_pagamento] = 'PREFERENCIALMENTE NAS CASAS LOTÉRICAS ATÉ O VALOR LIMITE'

        super(campos)
      end

      # Código do banco emissor
      # @return [String]
      def banco
        '104'
      end

      # Dígito verificador do código do banco em módulo 10
      # Módulo 10 de 104 é 0
      # @return [String]
      def banco_dv
        '0'
      end

      # Número do convênio/contrato do cliente junto ao banco.
      # @return [String] 6 caracteres numéricos.
      def convenio=(valor)
        @convenio = valor.to_s.rjust(6, '0') if valor
      end

      # Número seqüencial utilizado para identificar o boleto.
      # @return [String] 15 caracteres numéricos.
      def nosso_numero=(valor)
        @nosso_numero = valor.to_s.rjust(15, '0') if valor
      end

      # Nosso número, 17 dígitos
      # @return [String]
      def nosso_numero_boleto
        "#{carteira}#{emissao}#{nosso_numero}-#{nosso_numero_dv}"
      end

      # Dígito verificador do Nosso Número
      # Utiliza-se o [-1..-1] para retornar o último caracter
      # @return [String]
      def nosso_numero_dv
        "#{carteira}#{emissao}#{nosso_numero}".modulo11(
          multiplicador: (2..9).to_a,
          mapeamento: { 10 => 0, 11 => 0 }
        ) { |total| 11 - (total % 11) }.to_s
      end

      # Número da agência/código cedente do cliente para exibir no boleto.
      # @return [String]
      # @example
      #  boleto.agencia_conta_boleto #=> "1565/100000-4"
      def agencia_conta_boleto
        "#{agencia}/#{convenio}-#{convenio_dv}"
      end

      # Dígito verificador do convênio ou código do cedente
      # @return [String]
      def convenio_dv
        convenio.modulo11(
          multiplicador: (2..9).to_a,
          mapeamento: { 10 => 0, 11 => 0 }
        ) { |total| 11 - (total % 11) }.to_s
      end

      # Monta a segunda parte do código de barras.
      #  1 à 6: código do cedente, também conhecido como convênio
      #  7: dígito verificador do código do cedente
      #  8 à 10: dígito 3 à 5 do nosso número
      #  11: dígito 1 do nosso número (modalidade da cobrança)
      #  12 à 14: dígito 6 à 8 do nosso número
      #  15: dígito 2 do nosso número (emissão do boleto)
      #  16 à 24: dígito 9 à 17 do nosso número
      #  25: dígito verificador do campo livre
      # @return [String]
      def codigo_barras_segunda_parte
        campo_livre = "#{convenio}" \
        "#{convenio_dv}" \
        "#{nosso_numero_boleto[2..4]}" \
        "#{nosso_numero_boleto[0..0]}" \
        "#{nosso_numero_boleto[5..7]}" \
        "#{nosso_numero_boleto[1..1]}" \
        "#{nosso_numero_boleto[8..16]}"

        campo_livre.to_s +
          campo_livre.modulo11(
            multiplicador: (2..9).to_a,
            mapeamento: { 10 => 0, 11 => 0 }
          ) { |total| 11 - (total % 11) }.to_s
      end
    end
  end
end
