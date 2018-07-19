# -*- encoding: utf-8 -*-
module Brcobranca
  module Remessa
    module Cnab400
      class Santander < Brcobranca::Remessa::Cnab400::Base

        # Código de Transmissão
        # Consultar seu gerente para pegar esse código. Geralmente está no e-mail enviado pelo banco.
        attr_accessor :codigo_transmissao

        attr_accessor :codigo_carteira

        validates_presence_of :documento_cedente, :codigo_transmissao, message: 'não pode estar em branco.'
        validates_presence_of :digito_conta, message: 'não pode estar em branco.', if: :conta_padrao_novo?
        validates_length_of :documento_cedente, minimum: 11, maximum: 14, message: 'deve ter entre 11 e 14 dígitos.'
        validates_length_of :carteira, maximum: 3, message: 'deve ter no máximo 3 dígitos.'
        validates_length_of :codigo_transmissao, maximum: 20, message: 'deve ter no máximo 20 dígitos.'

        def initialize(campos = {})
          campos = { aceite: 'N', carteira: '101', codigo_carteira: '1' }.merge!(campos)
          super(campos)
        end

        def cod_banco
          '033'
        end

        def nome_banco
          'SANTANDER'.format_size(15)
        end

        def codigo_transmissao=(valor)
          @codigo_transmissao = valor.to_s.strip.rjust(20, '0') if valor
        end

        # Informacoes do Código de Transmissão
        #
        # @return [String]
        #
        def info_conta
          # CAMPO                     TAMANHO
          # codigo_transmissao        20
          codigo_transmissao
        end

        # Zeros do header
        #
        # @return [String]
        #
        def zeros
          "".ljust(16, "0")
        end


        # Complemento do header
        #
        # @return [String]
        #
        def complemento
          "".ljust(275, " ")
        end

        # Numero da versão da remessa
        #
        # @return [String]
        #
        def versao
          "058"
        end

        def monta_header
          # CAMPO                 TAMANHO    VALOR
          # tipo do registro      [1]        0
          # operacao              [1]        1
          # literal remessa       [7]        REMESSA
          # Código do serviço     [2]        01
          # cod. servico          [15]       COBRANCA
          # info. conta           [20]
          # empresa mae           [30]
          # cod. banco            [3]
          # nome banco            [15]
          # data geracao          [6]        formato DDMMAA
          # zeros                 [16]
          # complemento registro  [275]
          # versao                [3]
          # num. sequencial       [6]        000001
          "01REMESSA01COBRANCA       #{info_conta}#{empresa_mae[0..29].to_s.ljust(30, ' ')}#{cod_banco}#{nome_banco}#{data_geracao}#{zeros}#{complemento}#{versao}000001"
        end

        # Detalhe do arquivo
        #
        # @param pagamento [PagamentoCnab400]
        #   objeto contendo as informacoes referentes ao boleto (valor, vencimento, cliente)
        # @param sequencial
        #   num. sequencial do registro no arquivo
        #
        # @return [String]
        #
        def monta_detalhe(pagamento, sequencial)
          raise Brcobranca::RemessaInvalida, pagamento if pagamento.invalid?

          detalhe = '1'                                                     # identificacao transacao               9[01]
          detalhe << Brcobranca::Util::Empresa.new(documento_cedente).tipo  # tipo de identificacao da empresa      9[02]
          detalhe << documento_cedente.to_s.rjust(14, '0')                  # cpf/cnpj da empresa                   9[14]
          detalhe << codigo_transmissao                                     # Código de Transmissão                 9[20]
          detalhe << pagamento.documento_ou_numero.to_s.ljust(25, ' ')                                      # identificacao do tit. na empresa      X[25]
          detalhe << pagamento.nosso_numero.to_s.rjust(8, '0')              # nosso numero                          9[8]
          detalhe << pagamento.formata_data_segundo_desconto                # data limite para o segundo desconto   9[06]
          detalhe << ''.rjust(1, ' ')                                       # brancos                               X[1]
          detalhe << pagamento.codigo_multa                                 # Com multa = 4, Sem multa = 0          9[1]
          detalhe << pagamento.formata_percentual_multa                     # Percentual multa por atraso %         9[6]
          detalhe << '00'                                                   # Unidade de valor moeda corrente = 00  9[2]
          detalhe << '0'.rjust(13, '0')                                     # Valor do título em outra unidade      9[15]
          detalhe << ''.rjust(4, ' ')                                       # brancos                               X[4]
          detalhe << pagamento.formata_data_multa                           # Data para cobrança de multa           9[6]

          # codigo da carteira
          # 1 = ELETRÔNICA COM REGISTRO
          # 3 = CAUCIONADA ELETRÔNICA
          # 4 = COBRANÇA SEM REGISTRO
          # 5 = RÁPIDA COM REGISTRO
          # (BLOQUETE EMITIDO PELO CLIENTE) 6 = CAUCIONADA RAPIDA
          # 7 = DESCONTADA ELETRÔNICA
          detalhe << codigo_carteira                                        # codigo da carteira                    9[01]

          # Código da ocorrência:
          # 01 = ENTRADA DE TÍTULO
          # 02 = BAIXA DE TÍTULO
          # 04 = CONCESSÃO DE ABATIMENTO
          # 05 = CANCELAMENTO ABATIMENTO
          # 06 = PRORROGAÇÃO DE VENCIMENTO
          # 07 = ALT. NÚMERO CONT.CEDENTE
          # 08 = ALTERAÇÃO DO SEU NÚMERO
          # 09 = PROTESTAR
          # 18 = SUSTAR PROTESTO
          detalhe << pagamento.identificacao_ocorrencia                     # identificacao ocorrencia              9[02]
          detalhe << pagamento.numero.to_s.rjust(10, '0')         # numero do documento                   X[10]
          detalhe << pagamento.data_vencimento.strftime('%d%m%y')           # data do vencimento                    9[06]
          detalhe << pagamento.formata_valor                                # valor do documento                    9[13]
          detalhe << cod_banco                                              # codigo banco                          9[03]
          detalhe << ''.rjust(5, '0')                                       # agencia cobradora - deixar zero       9[05]

          # Espécie de documento:
          # 01 = DUPLICATA
          # 02 = NOTA PROMISSÓRIA
          # 03 = APÓLICE / NOTA DE SEGURO
          # 05 = RECIBO
          # 06 = DUPLICATA DE SERVIÇO
          # 07 = LETRA DE CAMBIO
          detalhe << pagamento.especie_titulo                               # Espécie de documento                  9[02]
          detalhe << aceite                                                 # aceite (A/N)                          X[01]
          detalhe << pagamento.data_emissao.strftime('%d%m%y')              # data de emissao                       9[06]

          # Instrução cobrança
          # 00 = NÃO HÁ INSTRUÇÕES
          # 02 = BAIXAR APÓS QUINZE DIAS DO VENCIMENTO
          # 03 = BAIXAR APÓS 30 DIAS DO VENCIMENTO
          # 04 = NÃO BAIXAR
          # 06 = PROTESTAR (VIDE POSIÇÃO392/393)
          # 07 = NÃO PROTESTAR
          # 08 = NÃO COBRAR JUROS DE MORA
          detalhe << pagamento.cod_primeira_instrucao                       # primeira instrução                    9[02]
          detalhe << pagamento.cod_segunda_instrucao                        # segunda instrução                     9[02]
          detalhe << pagamento.formata_valor_mora                           # valor mora ao dia                     9[13]
          detalhe << pagamento.formata_data_desconto                        # data limite para desconto             9[06]
          detalhe << pagamento.formata_valor_desconto                       # valor do desconto                     9[13]
          detalhe << pagamento.formata_valor_iof                            # valor do iof                          9[13]
          detalhe << pagamento.formata_valor_abatimento                     # valor do abatimento                   9[13]
          detalhe << pagamento.identificacao_sacado                         # identificacao do pagador              9[02]
          detalhe << pagamento.documento_sacado.to_s.rjust(14, '0')         # documento do pagador                  9[14]
          detalhe << pagamento.nome_sacado.format_size(40)                  # nome do pagador                       X[40]
          detalhe << pagamento.endereco_sacado.format_size(40)              # endereco do pagador                   X[40]
          detalhe << pagamento.bairro_sacado.format_size(12)                # bairro do pagador                     X[12]
          detalhe << pagamento.cep_sacado                                   # cep do pagador                        9[08]
          detalhe << pagamento.cidade_sacado.format_size(15)                # cidade do pagador                     X[15]
          detalhe << pagamento.uf_sacado                                    # uf do pagador                         X[02]
          detalhe << pagamento.nome_avalista.format_size(30)                # Sacador/Mensagens                     X[30]
          detalhe << ''.rjust(1, ' ')                                       # Brancos                               X[1]
          detalhe << identificador_movimento_complemento                    # Identificador do Complemento          X[1]
          detalhe << movimento_complemento                                  # Complemento                           9[2]
          detalhe << ''.rjust(6, ' ')                                       # Brancos                               X[06]
          # Se identificacao_ocorrencia = 06
          detalhe << pagamento.dias_protesto.rjust(2, '0')                  # Número de dias para protesto          9[02]
          detalhe << ''.rjust(1, ' ')                                       # Brancos                               X[1]
          detalhe << sequencial.to_s.rjust(6, '0')                          # numero do registro no arquivo         9[06]
          detalhe
        end

        def identificador_movimento_complemento
          return 'I' if conta_padrao_novo?
          ''.rjust(1, ' ')
        end

        def movimento_complemento
          return "#{conta_corrente[8]}#{digito_conta}" if conta_padrao_novo?
          ''.rjust(2, ' ')
        end

        def conta_padrao_novo?
          conta_corrente.present? && conta_corrente.length > 8
        end

        # Valor total de todos os títulos
        #
        # @return [String]
        #
        def total_titulos
          total = sprintf "%.2f", pagamentos.map(&:valor).inject(:+)
          total.to_s.somente_numeros.rjust(13, "0")
        end

        # Trailer do arquivo remessa
        #
        # @param sequencial
        #        num. sequencial do registro no arquivo
        #
        # @return [String]
        #
        def monta_trailer(sequencial)
          # CAMPO               TAMANHO   VALOR
          # código registro     [1]       9
          # quant. documentos   [6]
          # valor total titulos [13]
          # zeros               [374]     0
          # num. sequencial     [6]
          "9#{sequencial.to_s.rjust(6, '0')}#{total_titulos}#{''.rjust(374, '0')}#{sequencial.to_s.rjust(6, "0")}"
        end
      end
    end
  end
end
