# frozen_string_literal: true

module Brcobranca
  module Remessa
    module Cnab240
      # Banco Unicred (136)
      #
      # Layout proprio do Unicred, baseado no manual "COBRANCA UNICRED -
      # TROCA ELETRONICA CEDENTE CNAB 240 E 400" (item 6), disponivel em
      # docs/unicred. Difere do padrao generico FEBRABAN principalmente no
      # segmento P (posicao do nosso numero, carteira com 2 posicoes e
      # diversos campos tratados como filler) e no segmento R, onde ficam as
      # mensagens do titulo.
      class Unicred < Brcobranca::Remessa::Cnab240::Base
        # Parametro de movimento vinculado ao cedente no momento do
        # cadastramento (campo 22 do header de arquivo - UN001).
        attr_accessor :parametro_movimento

        validates_presence_of :agencia, :conta_corrente, :digito_conta, :documento_cedente,
                              message: 'não pode estar em branco.'
        validates_length_of :agencia, is: 4, message: 'deve ter 4 dígitos.'
        validates_length_of :conta_corrente, maximum: 12, message: 'deve ter no máximo 12 dígitos.'
        validates_length_of :digito_conta, is: 1, message: 'deve ter 1 dígito.'
        validates_length_of :carteira, is: 2, message: 'deve ter 2 dígitos.'
        validates_length_of :parametro_movimento, is: 3, message: 'deve ter 3 dígitos.'
        validates_inclusion_of :carteira, in: %w[21], message: 'não existente para este banco.'

        # Nova instancia do Unicred
        def initialize(campos = {})
          campos = {
            carteira: '21',
            parametro_movimento: '000',
            emissao_boleto: '2',
            distribuicao_boleto: '2',
            especie_titulo: '02',
            forma_cadastramento: '1',
            tipo_documento: '1'
          }.merge!(campos)
          super(campos)
        end

        def agencia=(valor)
          @agencia = valor.to_s.rjust(4, '0') if valor
        end

        def carteira=(valor)
          @carteira = valor.to_s.rjust(2, '0') if valor
        end

        # Codigo do banco na camara de compensacao
        # @return [String] 3 caracteres numericos.
        def cod_banco
          '136'
        end

        # Nome do banco
        # @return [String] 30 caracteres.
        def nome_banco
          'UNICRED'.ljust(30, ' ')
        end

        # Versao do layout do arquivo (campo 20 do header de arquivo)
        def versao_layout_arquivo
          '085'
        end

        # Versao do layout do lote (campo 7 do header de lote)
        def versao_layout_lote
          '044'
        end

        # Densidade de gravacao do arquivo: 1600 BPI
        def densidade_gravacao
          '01600'
        end

        # Digito verificador da agencia, calculado pelo modulo 11 com o mesmo
        # criterio usado na remessa CNAB 400 do Unicred.
        # @return [String] 1 caractere.
        def digito_agencia
          agencia.modulo11(mapeamento: { 10 => 'X' }).to_s
        end

        # Nosso numero com o digito verificador (campo 13 do segmento P).
        # @return [String] 11 caracteres numericos.
        def formata_nosso_numero(nosso_numero)
          numero = nosso_numero.to_s.somente_numeros.rjust(10, '0')
          "#{numero}#{numero.modulo11(mapeamento: { 10 => 0, 11 => 0 })}"
        end

        # O Unicred nao utiliza o codigo do convenio: campo 7 do header de
        # arquivo e campo 11 do header de lote sao filler.
        def codigo_convenio
          ''.rjust(20, ' ')
        end

        alias convenio_lote codigo_convenio

        # Informacoes da conta do cedente
        # (header de arquivo 053-072 / header de lote 054-073)
        #
        # @return [String] 20 caracteres.
        def info_conta
          # CAMPO           TAMANHO
          # agencia         5
          # dv agencia      1
          # conta corrente  12
          # dv conta        1
          # filler          1
          "#{agencia.rjust(5, '0')}#{digito_agencia}#{conta_corrente.to_s.rjust(12, '0')}#{digito_conta}0"
        end

        # Campos 22 e 23 do header de arquivo (posicoes 172 a 191):
        # parametro de movimento seguido do campo reservado ao banco.
        def uso_exclusivo_banco
          "#{parametro_movimento}#{''.rjust(17, ' ')}"
        end

        # Campo 24 do header de arquivo (posicoes 192 a 211)
        def uso_exclusivo_empresa
          ''.rjust(20, ' ')
        end

        # Campo 25 do header de arquivo (posicoes 212 a 240)
        def complemento_header
          ''.rjust(29, ' ')
        end

        # Complemento do trailer de lote (posicoes 24 a 240)
        #
        # @return [String] 217 caracteres.
        def complemento_trailer
          # CAMPO                                             TAMANHO
          # qtde de titulos em cobranca simples               6
          # valor total dos titulos em cobranca simples       17
          # qtde/valor dos titulos em cobranca vinculada      23
          # qtde/valor dos titulos em cobranca caucionada     23
          # qtde/valor dos titulos em cobranca descontada     23
          # numero do aviso de lancamento                     8
          # uso exclusivo FEBRABAN                            117
          cobranca_simples = "#{quantidade_titulos_cobranca}#{valor_titulos_carteira(17)}"
          "#{cobranca_simples}#{''.rjust(69, '0')}#{''.rjust(125, ' ')}"
        end

        # Complemento do segmento R (posicoes 180 a 240)
        #
        # @return [String] 61 caracteres.
        def complemento_r
          # CAMPO                    TAMANHO
          # uso exclusivo FEBRABAN   20
          # filler                   32
          # uso exclusivo FEBRABAN   9
          "#{''.rjust(20, ' ')}#{''.rjust(32, '0')}#{''.rjust(9, ' ')}"
        end

        # Monta o registro header do lote
        #
        # No layout do Unicred as duas mensagens do header de lote (posicoes
        # 104 a 183) e a data do credito (posicoes 200 a 207) sao filler - as
        # mensagens do titulo trafegam no segmento R.
        #
        # @return [String]
        #
        def monta_header_lote(nro_lote)
          header_lote = super
          header_lote[103, 80] = ''.rjust(80, ' ')
          header_lote[199, 8] = ''.rjust(8, ' ')
          header_lote
        end

        # Monta o registro segmento P do arquivo
        #
        # CAMPO                                 POSICAO  TAMANHO
        # codigo banco                          001-003  3
        # lote de servico                       004-007  4
        # tipo de registro                      008      1
        # num. sequencial do registro no lote   009-013  5
        # cod. segmento                         014      1
        # uso exclusivo FEBRABAN                015      1
        # cod. movimento remessa                016-017  2
        # agencia                               018-022  5
        # dv agencia                            023      1
        # conta corrente                        024-035  12
        # dv conta                              036      1
        # filler                                037      1
        # nosso numero (com dv)                 038-048  11
        # filler                                049-056  8
        # carteira                              057-058  2
        # filler                                059-062  4
        # numero do documento (seu numero)      063-077  15
        # data de vencimento                    078-085  8
        # valor nominal do titulo               086-100  15
        # agencia cobradora                     101-105  5
        # dv agencia cobradora                  106      1
        # filler                                107-108  2
        # aceite                                109      1
        # data de emissao do titulo             110-117  8
        # codigo do juros de mora               118      1
        # filler                                119-126  8
        # juros de mora por dia/taxa            127-141  15
        # codigo do desconto 1                  142      1
        # data do desconto 1                    143-150  8
        # valor/percentual do desconto 1        151-165  15
        # filler                                166-180  15
        # valor do abatimento                   181-195  15
        # identificacao do titulo na empresa    196-220  25
        # codigo para protesto                  221      1
        # prazo para protesto                   222-223  2
        # filler                                224-227  4
        # codigo da moeda                       228-229  2
        # numero do contrato                    230-239  10
        # uso exclusivo FEBRABAN                240      1
        #
        # @return [String]
        #
        def monta_segmento_p(pagamento, nro_lote, sequencial)
          segmento_p = ''
          segmento_p += cod_banco
          segmento_p << nro_lote.to_s.rjust(4, '0')
          segmento_p << '3'
          segmento_p << sequencial.to_s.rjust(5, '0')
          segmento_p << 'P'
          segmento_p << ' '
          segmento_p << pagamento.identificacao_ocorrencia
          segmento_p << agencia.rjust(5, '0')
          segmento_p << digito_agencia
          segmento_p << conta_corrente.to_s.rjust(12, '0')
          segmento_p << digito_conta.to_s
          segmento_p << '0'
          segmento_p << formata_nosso_numero(pagamento.nosso_numero)
          segmento_p << ''.rjust(8, ' ')
          segmento_p << carteira
          segmento_p << '0 0 '
          segmento_p << numero(pagamento)
          segmento_p << pagamento.data_vencimento.strftime('%d%m%Y')
          segmento_p << pagamento.formata_valor(15)
          segmento_p << ''.rjust(5, ' ')
          segmento_p << ' '
          segmento_p << ''.rjust(2, '0')
          segmento_p << aceite
          segmento_p << pagamento.data_emissao.strftime('%d%m%Y')
          segmento_p << pagamento.tipo_mora
          segmento_p << ''.rjust(8, '0')
          segmento_p << pagamento.formata_valor_mora(15)
          segmento_p << codigo_desconto(pagamento)
          segmento_p << pagamento.formata_data_desconto('%d%m%Y')
          segmento_p << pagamento.formata_valor_desconto(15)
          segmento_p << ''.rjust(15, '0')
          segmento_p << pagamento.formata_valor_abatimento(15)
          segmento_p << identificacao_titulo_empresa(pagamento)
          segmento_p << pagamento.codigo_protesto
          segmento_p << pagamento.dias_protesto.to_s.rjust(2, '0')
          segmento_p << '0'
          segmento_p << ''.rjust(3, ' ')
          segmento_p << '09'
          segmento_p << ''.rjust(10, '0')
          segmento_p << ' '
          segmento_p
        end

        # Monta o registro segmento R do arquivo
        #
        # No layout do Unicred os campos de desconto 2/3 e de multa sao filler;
        # o segmento carrega a informacao ao sacado e as duas mensagens.
        #
        # CAMPO                                 POSICAO  TAMANHO
        # codigo banco                          001-003  3
        # lote de servico                       004-007  4
        # tipo de registro                      008      1
        # num. sequencial do registro no lote   009-013  5
        # cod. segmento                         014      1
        # uso exclusivo FEBRABAN                015      1
        # cod. movimento remessa                016-017  2
        # filler (desconto 2 e desconto 3)      018-065  48
        # filler                                066      1
        # filler (multa)                        067-089  23
        # informacao ao sacado                  090-099  10
        # mensagem 1                            100-139  40
        # mensagem 2                            140-179  40
        # complemento                           180-240  61
        #
        # @return [String]
        #
        def monta_segmento_r(pagamento, nro_lote, sequencial)
          segmento_r = ''
          segmento_r += cod_banco
          segmento_r << nro_lote.to_s.rjust(4, '0')
          segmento_r << '3'
          segmento_r << sequencial.to_s.rjust(5, '0')
          segmento_r << 'R'
          segmento_r << ' '
          segmento_r << pagamento.identificacao_ocorrencia
          segmento_r << ''.rjust(48, '0')
          segmento_r << ' '
          segmento_r << ''.rjust(23, '0')
          segmento_r << ''.rjust(10, ' ')
          segmento_r << mensagem_1.to_s.format_size(40)
          segmento_r << mensagem_2.to_s.format_size(40)
          segmento_r << complemento_r
          segmento_r
        end

        # Monta o registro trailer do arquivo
        #
        # CAMPO                                 POSICAO  TAMANHO
        # codigo banco                          001-003  3
        # lote de servico                       004-007  4
        # tipo de registro                      008      1
        # uso exclusivo FEBRABAN                009-017  9
        # qtde de lotes do arquivo              018-023  6
        # qtde de registros do arquivo          024-029  6
        # qtde de contas para conciliacao       030-035  6
        # uso exclusivo FEBRABAN                036-240  205
        #
        # @return [String]
        #
        def monta_trailer_arquivo(nro_lotes, sequencial)
          trailer_arquivo = ''
          trailer_arquivo += cod_banco
          trailer_arquivo << '99999'
          trailer_arquivo << ''.rjust(9, ' ')
          trailer_arquivo << nro_lotes.to_s.rjust(6, '0')
          trailer_arquivo << sequencial.to_s.rjust(6, '0')
          trailer_arquivo << ''.rjust(6, '0')
          trailer_arquivo << ''.rjust(205, ' ')
          trailer_arquivo
        end
      end
    end
  end
end
