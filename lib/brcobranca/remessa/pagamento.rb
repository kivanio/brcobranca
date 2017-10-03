# -*- encoding: utf-8 -*-
#
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
      attr_accessor :numero_documento
      # <b>OPCIONAL</b>: data limite para o desconto
      attr_accessor :data_segundo_desconto
      # <b>OPCIONAL</b>: valor a ser concedido de desconto
      attr_accessor :valor_segundo_desconto
      # <b>OPCIONAL</b>: espécie do título
      attr_accessor :especie_titulo

      # <b>OPCIONAL</b>: código da multa
      #
      # Código adotado pela FEBRABAN para identificação do critério de
      # pagamento de pena pecuniária, a ser aplicada pelo atraso do pagamento
      # do Título.
      #
      # Domínio:
      # '1' = Valor Fixo
      # '2' = Percentual
      attr_accessor :codigo_multa

      # <b>OPCIONAL</b>: Valor/Percentual de multa por atraso
      #
      # Valor ou percentual de multa a ser aplicado sobre o valor do Título,
      # por atraso no pagamento.
      attr_accessor :percentual_multa
      alias_attribute :valor_multa, :percentual_multa

      # <b>OPCIONAL</b>: data da multa
      #
      # Data a partir da qual a multa deverá ser cobrada. Na ausência, será considerada a data de
      # vencimento.
      attr_accessor :data_multa

      # <b>OPCIONAL</b>: Número da Parcela
      attr_accessor :parcela
      # <b>OPCIONAL</b>: Dias para o protesto
      attr_accessor :dias_protesto
      # <b>OPCIONAL</b>: de livre utilização pela empresa, cuja informação não é consistida pelo Itaú, e não
      # sai no aviso de cobrança, retornando ao beneficiário no arquivo retorno em qualquer movimento do título
      # (baixa, liquidação, confirmação de protesto, etc.) com o mesmo conteúdo da entrada.
      attr_accessor :uso_da_empresa

      validates_presence_of :nosso_numero, :data_vencimento, :valor,
                            :documento_sacado, :nome_sacado, :endereco_sacado,
                            :cep_sacado, :cidade_sacado, :uf_sacado, message: 'não pode estar em branco.'
      validates_length_of :uf_sacado, is: 2, message: 'deve ter 2 dígitos.'
      validates_length_of :cep_sacado, is: 8, message: 'deve ter 8 dígitos.'
      validates_length_of :cod_desconto, is: 1, message: 'deve ter 1 dígito.'
      validates_length_of :especie_titulo, is: 2, message: 'deve ter 2 dígitos.', allow_blank: true
      validates_length_of :identificacao_ocorrencia, is: 2, message: 'deve ter 2 dígitos.'
      validates_length_of :uso_da_empresa, maximum: 25, message: 'deve ter no máximo 25 dígitos.', allow_blank: true, default: ''

      # Nova instancia da classe Pagamento
      #
      # @param campos [Hash]
      #
      def initialize(campos = {})
        padrao = {
          data_emissao: Date.current,
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
          parcela: '01'
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
        formata_data(data_desconto, formato)
      end

      # Formata a data de segundo desconto de acordo com o formato passado
      #
      # @return [String]
      #
      def formata_data_segundo_desconto(formato = '%d%m%y')
        formata_data(data_segundo_desconto, formato)
      end

      # Formata a data de cobrança da multa
      #
      # @return [String]
      #
      def formata_data_multa(formato = '%d%m%y')
        formata_data(data_multa, formato)
      end

      # Formata a data
      #
      # @return [String]
      #
      def formata_data(data, formato = '%d%m%y')
        data.strftime(formato)
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

      # Formata o juros de mora.
      # <b>Não implementado</b>
      #
      # Para utilização do juros de mora para Cnab240 utilizar:
      # Brcobranca::Remessa::Cnab240::Pagamento
      #
      # @return [String]
      #
      def formata_mora
        formata_campo_de_codigo_data_valor
      end

      # Formata a multa
      # <b>Não implementado</b>
      #
      # Para utilização da multa para Cnab240 utilizar:
      # Brcobranca::Remessa::Cnab240::Pagamento
      #
      # @return [String]
      #
      def formata_multa
        formata_campo_de_codigo_data_valor
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
      def formata_campo_de_codigo_data_valor
        campo_formatada = ''

        campo_formatada << '0'                # código                1   *
        campo_formatada << ''.rjust(8, '0')   # data                  8   *
        campo_formatada << ''.rjust(15, '0')  # valor                 15  *

        campo_formatada
      end

      def format_value(value, tamanho)
        raise ValorInvalido, 'Deve ser um Float' unless value.to_s =~ /\./

        sprintf('%.2f', value).delete('.').rjust(tamanho, '0')
      end
    end
  end
end
