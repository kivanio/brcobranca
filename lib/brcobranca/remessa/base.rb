# -*- encoding: utf-8 -*-
require 'unidecoder'

module Brcobranca
  module Remessa
    class Base
      # pagamentos da remessa (cada pagamento representa um registro detalhe no arquivo)
      attr_accessor :pagamentos
      # empresa mae (razao social)
      attr_accessor :empresa_mae
      # agencia (sem digito verificador)
      attr_accessor :agencia
      # numero da conta corrente
      attr_accessor :conta_corrente
      # digito verificador da conta corrente
      attr_accessor :digito_conta
      # carteira do cedente
      attr_accessor :carteira
      # sequencial remessa (num. sequencial que nao pode ser repetido nem zerado)
      attr_accessor :sequencial_remessa
      # aceite (A = ACEITO/N = NAO ACEITO)
      attr_accessor :aceite
      # documento do cedente (CPF/CNPJ)
      attr_accessor :documento_cedente

      # Validações
      include Brcobranca::Validations

      validates_presence_of :pagamentos, :empresa_mae, message: 'não pode estar em branco.'

      validates_each :pagamentos do |record, attr, value|
        if value.is_a? Array
          record.errors.add(attr, 'não pode estar vazio.') if value.empty?
          value.each do |pagamento|
            if pagamento.is_a? Brcobranca::Remessa::Pagamento
              if pagamento.invalid?
                pagamento.errors.full_messages.each { |msg| record.errors.add(attr, msg) }
              end
            else
              record.errors.add(attr, 'cada item deve ser um objeto Pagamento.')
            end
          end
        else
          record.errors.add(attr, 'deve ser uma coleção (Array).')
        end
      end

      # Nova instancia da classe
      #
      # @param campos [Hash]
      #
      def initialize(campos = {})
        campos = { aceite: 'N' }.merge!(campos)
        campos.each do |campo, valor|
          send "#{campo}=", valor
        end

        yield self if block_given?
      end

      def quantidade_titulos_cobranca
        pagamentos.length.to_s.rjust(6, "0")
      end

      def totaliza_valor_titulos
        pagamentos.inject(0.0) { |sum, pagamento| sum += pagamento.valor.to_f }
      end

      def valor_titulos_carteira(tamanho = 17)
        total = sprintf "%.2f", totaliza_valor_titulos
        total.somente_numeros.rjust(tamanho, "0")
      end

    end
  end
end
