# frozen_string_literal: true

module Brcobranca
  module Remessa
    class Pagamento
      include Brcobranca::Validations

      # Posicoes do campo X101 (Documento Fiscal) do Segmento X-03 do Split
      # Payment, veja o Layout Padrao Febraban 240 posicoes V11.0, pag. 84
      POSICOES_DOCUMENTO_FISCAL = 50

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
      # <b>OPCIONAL</b>: data limite para o terceiro desconto
      attr_accessor :data_terceiro_desconto
      # <b>OPCIONAL</b>: valor a ser concedido de desconto
      attr_accessor :valor_terceiro_desconto
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
      # <b>OPCIONAL</b>: Chave da Nota Fiscal Eletrônica
      attr_accessor :chave_nfe
      # <b>OPCIONAL</b>: Número da chave do Documento Fiscal (DF-e), campo X101
      # do Split Payment do IBS/CBS. É de preenchimento opcional quando o CBS e
      # o IBS Informado são informados
      attr_accessor :documento_fiscal
      # <b>OPCIONAL</b>: Valor do CBS Informado, campo X102 do Split Payment
      # do IBS/CBS. Precisa ser informado em conjunto com o IBS Informado
      attr_accessor :valor_cbs
      # <b>OPCIONAL</b>: Valor do IBS Informado, campo X103 do Split Payment
      # do IBS/CBS. Precisa ser informado em conjunto com o CBS Informado
      attr_accessor :valor_ibs

      validates_presence_of :nosso_numero, :data_vencimento, :valor,
                            :documento_sacado, :nome_sacado, :endereco_sacado,
                            :cep_sacado, :cidade_sacado, :uf_sacado, message: 'não pode estar em branco.'
      validates_length_of :uf_sacado, is: 2, message: 'deve ter 2 dígitos.'
      validates_length_of :cep_sacado, is: 8, message: 'deve ter 8 dígitos.'
      validates_length_of :cod_desconto, is: 1, message: 'deve ter 1 dígito.'
      validates_length_of :especie_titulo, is: 2, message: 'deve ter 2 dígitos.', allow_blank: true
      validates_length_of :identificacao_ocorrencia, is: 2, message: 'deve ter 2 dígitos.'

      # Regras dos valores informados do Split Payment: o CBS e o IBS Informado
      # precisam ser preenchidos sempre em conjunto, mesmo que um deles seja
      # zero, e a soma dos dois não pode ser superior ao valor nominal do título,
      # veja o Layout Padrão Febraban 240 posições V11.0, pág. 85 (códigos 'X2' e
      # 'X1' dos motivos da ocorrência do retorno).
      validates_each :valor_cbs do |pagamento, _atributo, _valor|
        cbs_informado = pagamento.valor_cbs
        ibs_informado = pagamento.valor_ibs

        if cbs_informado.nil? != ibs_informado.nil?
          pagamento.errors.add :valor_cbs, 'deve ser informado em conjunto com o IBS Informado.'
          next
        end
        # Sem o valor do titulo nao ha o que comparar (a presenca do valor e
        # validada a parte). Um titulo de valor zero entra na comparacao: nele
        # a soma do CBS e do IBS nao pode ser positiva.
        next if cbs_informado.nil? || pagamento.valor.nil?

        # A soma e comparada em centavos e com o mesmo arredondamento dos
        # campos X102/X103 (veja #formata_valor_split): somar os Floats de
        # origem recusaria um titulo valido (0.1 + 0.2 > 0.3) e um CBS de 5.005
        # e escrito como 5.00 no campo
        centavos = ->(valor) { format('%.2f', valor.to_f).delete('.').to_i }
        next if centavos.call(cbs_informado) + centavos.call(ibs_informado) <= centavos.call(pagamento.valor)

        pagamento.errors.add :valor_cbs,
                             'a soma do CBS e do IBS Informado não pode ser superior ao valor do título.'
      end

      # Nova instancia da classe Pagamento
      #
      # @param campos [Hash]
      #
      def initialize(campos = {})
        padrao = {
          data_emissao: Date.current,
          data_segundo_desconto: '00-00-00',
          data_terceiro_desconto: '00-00-00',
          tipo_mora: '3',
          valor_mora: 0.0,
          valor_desconto: 0.0,
          valor_segundo_desconto: 0.0,
          valor_terceiro_desconto: 0.0,
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
          send :"#{campo}=", valor
        end

        yield self if block_given?
      end

      # Formata a data de desconto de acordo com o formato passado
      #
      # @return [String]
      #
      def formata_data_desconto(formato = '%d%m%y')
        data_desconto.strftime(formato)
      rescue StandardError
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
      rescue StandardError
        if formato == '%d%m%y'
          '000000'
        else
          '00000000'
        end
      end

      # Formata a data de terceiro desconto de acordo com o formato passado
      #
      # @return [String]
      #
      def formata_data_terceiro_desconto(formato = '%d%m%y')
        data_terceiro_desconto.strftime(formato)
      rescue StandardError
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
        format_value(:percentual_multa, tamanho)
      end

      # Formata a data de cobrança da multa
      #
      # @return [String]
      #
      def formata_data_multa(formato = '%d%m%y')
        data_multa.strftime(formato)
      rescue StandardError
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
        format_value(:valor, tamanho)
      end

      def documento_ou_numero
        documento || numero
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
        format_value(:valor_mora, tamanho)
      end

      # Formata o campo valor da multa
      #
      # @param tamanho [Integer]
      #   quantidade de caracteres a ser retornado
      #
      def formata_valor_multa(tamanho = 6)
        format_value(:percentual_multa, tamanho)
      end

      # Formata o campo valor do desconto
      #
      # @param tamanho [Integer]
      #   quantidade de caracteres a ser retornado
      #
      def formata_valor_desconto(tamanho = 13)
        format_value(:valor_desconto, tamanho)
      end

      # Formata o campo valor do segundo desconto
      #
      # @param tamanho [Integer]
      #   quantidade de caracteres a ser retornado
      #
      def formata_valor_segundo_desconto(tamanho = 13)
        format_value(:valor_segundo_desconto, tamanho)
      end

      # Formata o campo valor do terceiro desconto
      #
      # @param tamanho [Integer]
      #   quantidade de caracteres a ser retornado
      #
      def formata_valor_terceiro_desconto(tamanho = 13)
        format_value(:valor_terceiro_desconto, tamanho)
      end

      # Formata o campo valor do IOF
      #
      # @param tamanho [Integer]
      #   quantidade de caracteres a ser retornado
      #
      def formata_valor_iof(tamanho = 13)
        format_value(:valor_iof, tamanho)
      end

      # Formata o campo valor do IOF
      #
      # @param tamanho [Integer]
      #   quantidade de caracteres a ser retornado
      #
      def formata_valor_abatimento(tamanho = 13)
        format_value(:valor_abatimento, tamanho)
      end

      # Verifica se o titulo gera o registro opcional Segmento X-03 do Split
      # Payment do IBS/CBS, veja Brcobranca::Remessa::Cnab240::Base#monta_lote.
      #
      # O Recebedor sinaliza a opcao pelo Split Payment informando o CBS e o IBS
      # Informado (campos X102 e X103) - os dois sempre em conjunto, mesmo que um
      # deles seja zero - e a Chave do Documento Fiscal (X101) fica opcional:
      # "ao realizar o preenchimento, o Recebedor sinaliza a opcao por utilizar o
      # Split Payment" (Layout Padrao Febraban 240 posicoes V11.0, pag. 85).
      #
      # O Codigo de Movimento (campo C004) nao entra na decisao de proposito. A
      # norma define o dominio de C004, mas cada Banco escolhe os codigos que
      # aceita - o mesmo codigo pode nao existir no Banco, ter outro significado
      # ou nao ser o evento em que o Segmento X-03 e previsto -, e essa lista
      # nao caberia aqui: Pagamento e comum a todos os Bancos e a gem nao tem a
      # tabela de codigos de cada um. Quem monta o titulo (o ERP, que tem a
      # tabela do Banco) sinaliza o registro preenchendo o CBS/IBS Informado nos
      # movimentos em que o Banco preve o Segmento X-03, e nao preenche nos
      # demais.
      #
      # @return [Boolean]
      #
      def split_payment?
        !valor_cbs.nil? && !valor_ibs.nil?
      end

      # Formata a chave do Documento Fiscal (campo X101) em 50 posicoes
      #
      # O campo e Alfa no layout e a chave do DF-e pode ter letras (o CNPJ
      # alfanumerico entra na composicao da chave), por isso so a pontuacao e
      # removida: filtrar apenas os digitos truncaria a chave.
      #
      # @param tamanho [Integer]
      #   quantidade de caracteres a ser retornado
      #
      # @return [String]
      #
      # @raise [Brcobranca::ValorInvalido] quando a chave nao cabe nas posicoes
      #   do campo X101: a chave cortada identificaria outro Documento Fiscal
      #   para o Banco.
      #
      def formata_documento_fiscal(tamanho = POSICOES_DOCUMENTO_FISCAL)
        chave = documento_fiscal.to_s.gsub(/[^0-9A-Za-z]/, '').upcase

        if chave.size > POSICOES_DOCUMENTO_FISCAL
          raise ValorInvalido,
                "#{self.class}#formata_documento_fiscal: a chave do Documento Fiscal tem #{chave.size} " \
                "caracteres e nao cabe nas #{POSICOES_DOCUMENTO_FISCAL} posicoes do campo X101"
        end

        chave.ljust(tamanho, ' ')[0...tamanho]
      end

      # Formata o valor do CBS Informado (campo X102) no padrao 13,2
      #
      # @param tamanho [Integer]
      #   quantidade de caracteres a ser retornado
      #
      # @return [String]
      #
      def formata_valor_cbs(tamanho = 15)
        formata_valor_split(valor_cbs, tamanho)
      end

      # Formata o valor do IBS Informado (campo X103) no padrao 13,2
      #
      # @param tamanho [Integer]
      #   quantidade de caracteres a ser retornado
      #
      # @return [String]
      #
      def formata_valor_ibs(tamanho = 15)
        formata_valor_split(valor_ibs, tamanho)
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

      # Formata os valores informados do Split Payment (CBS/IBS), campos
      # X102 e X103 do Layout Padrao Febraban 240 posicoes V11.0: 13 digitos,
      # sendo 2 decimais.
      #
      # @param valor [Numeric]
      #
      # @param tamanho [Integer]
      #   quantidade de caracteres a ser retornado
      #
      # @return [String]
      #
      # @raise [Brcobranca::ValorInvalido] quando o valor nao e numerico (o
      #   `to_f` de uma String devolveria 0.0 para 'abc' ou 1.0 para '1,80' e o
      #   campo sairia preenchido com um valor que o Recebedor nao informou),
      #   nao e um numero finito, e negativo ou nao cabe nas posicoes do campo.
      #   Um valor maior deixa o registro com mais de 240 posicoes e um negativo
      #   coloca um sinal no campo numerico.
      #
      def formata_valor_split(valor, tamanho = 13)
        valida_tipo_valor_split!(valor)

        valor = valor.to_f
        # O -0.0 e igual a zero, mas o format mantem o sinal e o campo
        # numerico sairia com um hifen (X102/X103 sao Numeric 13,2)
        valor = 0.0 if valor.zero?
        valor_formatado = format('%.2f', valor).delete('.')

        if !valor.finite? || valor.negative? || valor_formatado.size > tamanho
          raise ValorInvalido,
                "#{self.class}#formata_valor_split: #{valor} nao cabe nas #{tamanho} posicoes do " \
                'campo (13 digitos, sendo 2 decimais)'
        end

        valor_formatado.rjust(tamanho, '0')
      end

      # Valida que o valor informado do Split Payment (CBS/IBS) e um Numeric
      #
      # @param valor [Numeric]
      #
      # @raise [Brcobranca::ValorInvalido] quando o valor nao e numerico
      #
      def valida_tipo_valor_split!(valor)
        return if valor.is_a?(Numeric)

        raise ValorInvalido,
              "#{self.class}#formata_valor_split: #{valor.inspect} deve ser um numero (Numeric)"
      end

      def format_value(attribute, tamanho)
        value = send(attribute)

        raise ValorInvalido, "#{self.class}##{attribute}: Deve ser um Float" unless value.to_s.include?('.')

        format('%.2f', value).delete('.').rjust(tamanho, '0')
      end
    end
  end
end
