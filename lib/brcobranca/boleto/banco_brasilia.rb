# -*- encoding: utf-8 -*-
#
module Brcobranca
  module Boleto
    class BancoBrasilia < Base # Banco Brasilia

      # <b>OPCIONAL</b>: Incremento do Campo Livre do Nosso Número
      attr_accessor :nosso_numero_incremento

      # Validações
      # Modalidade/Carteira de Cobrança (1-Sem Registro | 2-Registrada)
      validates_length_of :agencia, is: 3, message: 'deve possuir 3 dígitos.'
      validates_length_of :carteira, is: 1, message: 'deve possuir 1 dígito.'
      validates_length_of :nosso_numero, maximum: 6, message: 'deve ser menor ou igual a 6 dígitos.'
      validates_length_of :conta_corrente, maximum: 7, message: 'deve ser menor ou igual a 7 dígitos.'
      validates_length_of :nosso_numero_incremento, maximum: 3, message: 'deve ser menor ou igual a 3 dígitos.'
      validates_presence_of :nosso_numero_incremento, message: 'não pode estar em branco.'

      # Nova instância da BancoBrasilia
      # @param (see Brcobranca::Boleto::Base#initialize)
      def initialize(campos = {})
        campos = {
          carteira: '2',
          nosso_numero_incremento: '000',
          local_pagamento: 'PAGÁVEL EM QUALQUER BANCO ATÉ O VENCIMENTO'
        }.merge!(campos)

        super(campos)
      end

      # Código do banco emissor
      # @return [String]
      def banco
        '070'
      end

      # Número da agência
      # @return [String] 3 caracteres numéricos.
      def agencia=(valor)
        @agencia = valor.to_s.rjust(3, '0') if valor
      end

      # Conta corrente
      # @return [String] 7 caracteres numéricos.
      def conta_corrente=(valor)
        @conta_corrente = valor.to_s.rjust(7, '0') if valor
      end

      # Número seqüencial utilizado para identificar o boleto.
      # @return [String] 6 caracteres numéricos.
      def nosso_numero=(valor)
        @nosso_numero = valor.to_s.rjust(6, '0') if valor
      end

      # Incremento do Campo Livre do Nosso Número
      # @return [String] 3 caracteres numéricos.
      def nosso_numero_incremento=(valor)
        @nosso_numero_incremento = valor.to_s.rjust(3, '0') if valor
      end

      # Nosso número boleto
      # @return [String]
      def nosso_numero_boleto
        "#{carteira}#{nosso_numero}070#{codigo_barras_segunda_parte[-2..-1]}"
      end

      # Número da agência/código cedente do cliente para exibir no boleto.
      # @return [String]
      # @example
      #  boleto.agencia_conta_boleto #=> "1565/100000-4"
      def agencia_conta_boleto
        "000 - #{agencia} - #{conta_corrente}"
      end

      # Monta a segunda parte do código de barras.
      #
      # @return [String]
      # POSIÇÃO | Tamanho| NOME DO CAMPO                             | CONTEÚDO/DESCRIÇÃO
      # 1  - 3  | 3      | Incremento do Campo Livre do Nosso Número | Incremento do Campo livre. Tal incremento é opcional e uma vez utilizado deverá ser concatenado com as posições 2 a 7 do Nosso Número.
      # 4  - 13 | 10     | Código do Beneficiário (Agencia/Conta)            | Conta corrente de cobrança
      # 14 - 25 | 12     | Nosso Número                              | Nosso Número. O formato é MSSSSSS070dd, em que M=Modalidade, S=Sequencial (campo livre do Nosso Número), 070-fixo, dd=Dígitos
      #
      # Composição do Nosso Número
      # POSIÇÃO | Tamanho | NOME DO CAMPO          | CONTEÚDO/DESCRIÇÃO
      # 1 - 3   | 1       | Modalidade de Cobrança | Informar a modalidade de cobrança conforme a seguir:
      #                                              1: Direta Modalidade 1;
      #                                              2: Direta Modalidade 2;
      #                                              3: Modalidade 3 (emissão BRB)
      #                                              As modalidades 1 e 2 são para a emissão local e a 3 para a emissão BRB.
      #                                              Neste caso, o padrão é postagem SIM.
      # 4 - 9   | 6       | Campo Livre do Nosso Número | Neste campo livre, deve o sistema do sistema do Beneficiário controlar e identificar o boleto em sua carteira.
      #                                                   Pode ser incrementado por meio das posições 1 a 3 da Chave BRB. Não são admitidas duplicidades.
      # 10 - 12 | 3        | Banco    | 070
      # 13 - 13 | 1        | Dígito 1 | Calcula-se utilizando-se o sistema de “Módulo 10”, pesos 2 e 1. Ver detalhe ao lado.
      # 14 - 14 | 1        | Dígito 2 | Calcula-se utilizando o sistema de “Modulo 11”, pesos de 2 a 7, com exceções quando o resto é igual a 0 e igual a 1. Ver detalhe ao lado.
      def codigo_barras_segunda_parte
        campo_livre = "#{nosso_numero_incremento}#{agencia}#{conta_corrente}#{carteira}#{nosso_numero}070"
        campo_livre + campo_livre.duplo_digito
      end
    end
  end
end
