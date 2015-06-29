# encoding: utf-8

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

      # Validações do Rails 3
      include ActiveModel::Validations

      validates_presence_of :pagamentos, :empresa_mae, :agencia, :conta_corrente, message: 'não pode estar em branco.'
      validates_length_of :empresa_mae, maximum: 30, message: 'deve ser menor ou igual a 30 caracteres.'

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

    end
  end
end