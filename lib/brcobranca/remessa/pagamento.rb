# -*- encoding: utf-8 -*-
module Brcobranca
  module Remessa
    class Pagamento

      include Brcobranca::Validations

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
      # <b>REQUERIDO</b>: Código da ocorrência
      attr_accessor :identificacao_ocorrencia
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
      # <b>OPCIONAL</b>: Número do Documento de Cobrança - Número adotado e controlado pelo Cliente,
      # para identificar o título de cobrança.
      # Informação utilizada para referenciar a identificação do documento objeto de cobrança.
      # Poderá conter número de duplicata, no caso de cobrança de duplicatas; número da apólice,
      # no caso de cobrança de seguros, etc
      attr_accessor :numero
      # <b>OPCIONAL</b>: Número utilizado para controle do beneficiário/cedente
      attr_accessor :documento
      # <b>OPCIONAL</b>: data limite para o desconto
      attr_accessor :data_segundo_desconto
      # <b>OPCIONAL</b>: valor a ser concedido de desconto
      attr_accessor :valor_segundo_desconto
      # <b>OPCIONAL</b>: espécie do título
      attr_accessor :especie_titulo
      # <b>OPCIONAL</b>: código da multa
      attr_accessor :codigo_multa
      # <b>OPCIONAL</b>: Percentual multa por atraso %
      attr_accessor :percentual_multa
      # <b>OPCIONAL</b>: Data para cobrança de multa
      attr_accessor :data_multa
      # <b>OPCIONAL</b>: tipo de mora (diário, mensal)
      attr_accessor :tipo_mora
      # <b>OPCIONAL</b>: Data para cobrança de mora
      attr_accessor :data_mora
      # <b>OPCIONAL</b>: codigo dos juros
      attr_accessor :codigo_juros
      # <b>OPCIONAL</b>: codigo do protesto
      attr_accessor :codigo_protesto
      # <b>OPCIONAL</b>: dias para protesto
      attr_accessor :dias_protesto
      # <b>OPCIONAL</b>: codigo baixa
      attr_accessor :codigo_baixa
      # <b>OPCIONAL</b>: dias para baixa
      attr_accessor :dias_baixa
      # <b>OPCIONAL</b>: Número da Parcela
      attr_accessor :parcela

      validates_presence_of :nosso_numero, :data_vencimento, :valor,
        :documento_sacado, :nome_sacado, :endereco_sacado,
        :cep_sacado, :cidade_sacado, :uf_sacado, message: 'não pode estar em branco.'
      validates_length_of :uf_sacado, is: 2, message: 'deve ter 2 dígitos.'
      validates_length_of :cep_sacado, is: 8, message: 'deve ter 8 dígitos.'
      validates_length_of :cod_desconto, is: 1, message: 'deve ter 1 dígito.'
      validates_length_of :especie_titulo, is: 2, message: 'deve ter 2 dígitos.', allow_blank: true
      validates_length_of :identificacao_ocorrencia, is: 2, message: 'deve ter 2 dígitos.'

      # Nova instancia da classe Pagamento
      #
      # @param campos [Hash]
      #
      def initialize(campos = {})
        padrao = {
          data_emissao: Date.current,
          data_segundo_desconto:'00-00-00',
          tipo_mora: "3",
          valor_mora: 0.0,
          valor_desconto: 0.0,
          valor_segundo_desconto: 0.0,
          valor_iof: 0.0,
          valor_abatimento: 0.0,
          nome_avalista: '',
          cod_desconto: '0',
          especie_titulo: '01',
          identificacao_ocorrencia: '01',
          codigo_multa: '0',
          percentual_multa: 0.0,
          parcela: '01',
          codigo_protesto: '3',
          dias_protesto: '00',
          codigo_baixa: '0',
          dias_baixa: '000',
          cod_primeira_instrucao: '00',
          cod_segunda_instrucao: '00'
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

      # Formata a data de segundo desconto de acordo com o formato passado
      #
      # @return [String]
      #
      def formata_data_segundo_desconto(formato = '%d%m%y')
        data_segundo_desconto.strftime(formato)
      rescue
        if formato == '%d%m%y'
          '000000'
        else
          '00000000'
        end
      end

      # Formata a valor do percentual da multa
      #
      # @param tamanho [Integer]
      #   quantidade de caracteres a ser retornado
      #
      # @return [String]
      #
      def formata_percentual_multa(tamanho = 4)
        format_value(percentual_multa, tamanho)
      end

      # Formata a data de cobrança da multa
      #
      # @return [String]
      #
      def formata_data_multa(formato = '%d%m%y')
        data_multa.strftime(formato)
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
        format_value(valor, tamanho)
      end

      def documento_ou_numero
        documento.present? ? documento : numero
      end

      def formata_documento_ou_numero(tamanho = 25, caracter = ' ')
        doc = documento_ou_numero.to_s.gsub(/[^0-9A-Za-z ]/, '')
        doc.rjust(tamanho, caracter)[0...tamanho]
      end

      # Formata o campo valor da mora
      #
      # @param tamanho [Integer]
      #   quantidade de caracteres a ser retornado
      #
      def formata_valor_mora(tamanho = 13)
        format_value(valor_mora, tamanho)
      end

      # Formata o campo valor da multa
      #
      # @param tamanho [Integer]
      #   quantidade de caracteres a ser retornado
      #
      def formata_valor_multa(tamanho = 6)
        format_value(percentual_multa, tamanho)
      end

      # Formata o campo valor do desconto
      #
      # @param tamanho [Integer]
      #   quantidade de caracteres a ser retornado
      #
      def formata_valor_desconto(tamanho = 13)
        format_value(valor_desconto, tamanho)
      end

      # Formata o campo valor do segundo desconto
      #
      # @param tamanho [Integer]
      #   quantidade de caracteres a ser retornado
      #
      def formata_valor_segundo_desconto(tamanho = 13)
        format_value(valor_segundo_desconto, tamanho)
      end

      # Formata o campo valor do IOF
      #
      # @param tamanho [Integer]
      #   quantidade de caracteres a ser retornado
      #
      def formata_valor_iof(tamanho = 13)
        format_value(valor_iof, tamanho)
      end

      # Formata o campo valor do IOF
      #
      # @param tamanho [Integer]
      #   quantidade de caracteres a ser retornado
      #
      def formata_valor_abatimento(tamanho = 13)
        format_value(valor_abatimento, tamanho)
      end

      # Retorna a identificacao do pagador
      # Se for pessoa fisica (CPF com 11 digitos) é 1
      # Se for juridica (CNPJ com 14 digitos) é 2
      #
      def identificacao_sacado(zero = true)
        Brcobranca::Util::Empresa.new(documento_sacado, zero).tipo
      end

      # Retorna a identificacao do avalista
      # Se for pessoa fisica (CPF com 11 digitos) é 1
      # Se for juridica (CNPJ com 14 digitos) é 2
      #
      def identificacao_avalista(zero = true)
        return '0' if documento_avalista.nil?
        Brcobranca::Util::Empresa.new(documento_avalista, zero).tipo
      end

      private

      def format_value(value, tamanho)
        raise ValorInvalido, 'Deve ser um Float' unless value.to_s =~ /\./

        sprintf('%.2f', value).delete('.').rjust(tamanho, '0')
      end
    end
  end
end
