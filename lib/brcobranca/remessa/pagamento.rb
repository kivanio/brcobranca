# -*- encoding: utf-8 -*-
module Brcobranca
  module Remessa
    class Pagamento

      # Validações do Rails 3
      include ActiveModel::Validations

      # <b>REQUERIDO</b>: nosso numero
      attr_accessor :nosso_numero
      # <b>REQUERIDO</b>: data do vencimento do boleto
      attr_accessor :data_vencimento
      # <b>REQUERIDO</b>: data de emissao do boleto
      attr_accessor :data_emissao
      # <b>REQUERIDO</b>: valor do boleto
      attr_accessor :valor
      # <b>REQUERIDO</b>: documento do sacado (cliente)
      attr_accessor :documento_sacado
      # <b>REQUERIDO</b>: nome do sacado (cliente)
      attr_accessor :nome_sacado
      # <b>REQUERIDO</b>: endereco do sacado (cliente)
      attr_accessor :endereco_sacado
      # <b>REQUERIDO</b>: bairro do sacado (cliente)
      attr_accessor :bairro_sacado
      # <b>REQUERIDO</b>: CEP do sacado (cliente)
      attr_accessor :cep_sacado
      # <b>REQUERIDO</b>: cidade do sacado (cliente)
      attr_accessor :cidade_sacado
      # <b>REQUERIDO</b>: UF do sacado (cliente)
      attr_accessor :uf_sacado
      # <b>OPCIONAL</b>: nome do avalista
      attr_accessor :nome_avalista
      # <b>OPCIONAL</b>: documento do avalista
      attr_accessor :documento_avalista
      # <b>OPCIONAL</b>: codigo da 1a instrucao
      attr_accessor :cod_primeira_instrucao
      # <b>OPCIONAL</b>: codigo da 2a instrucao
      attr_accessor :cod_segunda_instrucao
      # <b>OPCIONAL</b>: valor da mora ao dia
      attr_accessor :valor_mora
      # <b>OPCIONAL</b>: data limite para o desconto
      attr_accessor :data_desconto
      # <b>OPCIONAL</b>: valor a ser concedido de desconto
      attr_accessor :valor_desconto
      # <b>OPCIONAL</b>: codigo do desconto (para CNAB240)
      attr_accessor :cod_desconto
      # <b>OPCIONAL</b>: valor do IOF
      attr_accessor :valor_iof
      # <b>OPCIONAL</b>: valor do abatimento
      attr_accessor :valor_abatimento

      validates_presence_of :nosso_numero, :data_vencimento, :valor,
                            :documento_sacado, :nome_sacado, :endereco_sacado,
                            :cep_sacado, :cidade_sacado, :uf_sacado, message: 'não pode estar em branco.'
      validates_length_of :cep_sacado, is: 8, message: 'deve ter 8 dígitos.'
      validates_length_of :cod_desconto, is: 1, message: 'deve ter 1 dígito.'

      # Nova instancia da classe Pagamento
      #
      # @param campos [Hash]
      #
      def initialize(campos = {})
        padrao = {
            data_emissao: Date.today,
            valor_mora: 0.0,
            valor_desconto: 0.0,
            valor_iof: 0.0,
            valor_abatimento: 0.0,
            nome_avalista: '',
            cod_desconto: '0'
        }

        campos = padrao.merge!(campos)
        campos.each do |campo, valor|
          send "#{campo}=", valor
        end

        yield self if block_given?
      end

      # Formata a data de desconto de acordo com o formato passado
      #
      # @return [String]
      #
      def formata_data_desconto(formato = '%d%m%y')
        data_desconto.strftime(formato)
      rescue
        if formato == '%d%m%y'
          '000000'
        else
          '00000000'
        end
      end

      # Formata o campo valor
      # referentes as casas decimais
      # exe. R$199,90 => 0000000019990
      #
      # @param tamanho [Integer]
      #   quantidade de caracteres a ser retornado
      #
      def formata_valor(tamanho = 13)
        sprintf('%.2f', valor).delete('.').rjust(tamanho, '0')
      end

      # Formata o campo valor da mora
      #
      # @param tamanho [Integer]
      #   quantidade de caracteres a ser retornado
      #
      def formata_valor_mora(tamanho = 13)
        sprintf('%.2f', valor_mora).delete('.').rjust(tamanho, '0')
      end

      # Formata o campo valor do desconto
      #
      # @param tamanho [Integer]
      #   quantidade de caracteres a ser retornado
      #
      def formata_valor_desconto(tamanho = 13)
        sprintf('%.2f', valor_desconto).delete('.').rjust(tamanho, '0')
      end

      # Formata o campo valor do IOF
      #
      # @param tamanho [Integer]
      #   quantidade de caracteres a ser retornado
      #
      def formata_valor_iof(tamanho = 13)
        sprintf('%.2f', valor_iof).delete('.').rjust(tamanho, '0')
      end

      # Formata o campo valor do IOF
      #
      # @param tamanho [Integer]
      #   quantidade de caracteres a ser retornado
      #
      def formata_valor_abatimento(tamanho = 13)
        sprintf('%.2f', valor_abatimento).delete('.').rjust(tamanho, '0')
      end

      # Retorna a identificacao do pagador
      # Se for pessoa fisica (CPF com 11 digitos) é 1
      # Se for juridica (CNPJ com 14 digitos) é 2
      #
      def identificacao_sacado(tamanho = 2)
        documento_sacado.size < 14 ? '1'.rjust(tamanho, '0') : '2'.rjust(tamanho, '0')
      end

      # Retorna a identificacao do avalista
      # Se for pessoa fisica (CPF com 11 digitos) é 1
      # Se for juridica (CNPJ com 14 digitos) é 2
      #
      def identificacao_avalista(tamanho = 2)
        return 0 if documento_avalista.nil?
        documento_avalista.size < 14 ? '1'.rjust(tamanho, '0') : '2'.rjust(tamanho, '0')
      end
    end
  end
end