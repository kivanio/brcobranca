# -*- encoding: utf-8 -*-
#
module Brcobranca
  module Remessa
    module Cnab240
      class Sicoob < Brcobranca::Remessa::Cnab240::Base
        attr_accessor :modalidade_carteira
        # identificacao da emissao do boleto (attr na classe base)
        #   opcoes:
        #     ‘1’ = Banco Emite
        #     ‘2’ = Cliente Emite
        #
        # identificacao da distribuicao do boleto (attr na classe base)
        #   opcoes:
        #     ‘1’ = Banco distribui
        #     ‘2’ = Cliente distribui

        attr_accessor :tipo_formulario
        #       Tipo Formulário - 01 posição  (15 a 15):
        #            "1" -auto-copiativo
        #            "3" -auto-envelopável
        #            "4" -A4 sem envelopamento
        #            "6" -A4 sem envelopamento 3 vias

        validates_presence_of :modalidade_carteira, :tipo_formulario, message: 'não pode estar em branco.'
        # Remessa 400 - 8 digitos
        # Remessa 240 - 12 digitos
        validates_length_of :conta_corrente, maximum: 8, message: 'deve ter 8 dígitos.'
        validates_length_of :agencia, is: 4, message: 'deve ter 4 dígitos.'
        validates_length_of :modalidade_carteira, is: 2, message: 'deve ter 2 dígitos.'

        def initialize(campos = {})
          campos = { emissao_boleto: '2',
                     distribuicao_boleto: '2',
                     tipo_formulario: '4',
                     modalidade_carteira: '01',
                     forma_cadastramento: '0' }.merge!(campos)
          super(campos)
        end

        def cod_banco
          '756'
        end

        def nome_banco
          'SICOOB'.ljust(30, ' ')
        end

        def versao_layout_arquivo
          '081'
        end

        def versao_layout_lote
          '040'
        end

        def digito_agencia
          # utilizando a agencia com 4 digitos
          # para calcular o digito
          agencia.modulo11(mapeamento: { 10 => 'X' }).to_s
        end

        def digito_conta
          # utilizando a conta corrente com 5 digitos
          # para calcular o digito
          conta_corrente.modulo11(mapeamento: { 10 => 'X' }).to_s
        end

        def codigo_convenio
          # CAMPO                TAMANHO
          # num. convenio        20 BRANCOS
          ''.rjust(20, ' ')
        end

        alias convenio_lote codigo_convenio

        def info_conta
          # CAMPO                  TAMANHO
          # agencia                5
          # digito agencia         1
          # conta corrente         12
          # digito conta           1
          # digito agencia/conta   1
          "#{agencia.rjust(5, '0')}#{digito_agencia}#{conta_corrente.rjust(12, '0')}#{digito_conta} "
        end

        def complemento_header
          ''.rjust(29, ' ')
        end

        def complemento_trailer
          ''.rjust(117, ' ')
        end

        def monta_segmento_p(pagamento, nro_lote, sequencial)
          # campos com * na frente nao foram implementados
          #                                                             # DESCRICAO                             TAMANHO
          segmento_p = cod_banco # codigo banco                          3
          segmento_p << nro_lote.to_s.rjust(4, '0') # lote de servico                       4
          segmento_p << '3' # tipo de registro                      1
          segmento_p << sequencial.to_s.rjust(5, '0') # num. sequencial do registro no lote   5
          segmento_p << 'P' # cod. segmento                         1
          segmento_p << ' ' # uso exclusivo                         1
          segmento_p << '01' # cod. movimento remessa                2
          segmento_p << agencia.to_s.rjust(5, '0') # agencia                               5
          segmento_p << digito_agencia.to_s # dv agencia                            1
          segmento_p << complemento_p(pagamento) # informacoes da conta                  34
          segmento_p << codigo_carteira # codigo da carteira                    1
          segmento_p << forma_cadastramento # forma de cadastro do titulo           1
          segmento_p << tipo_documento # tipo de documento                     1
          segmento_p << emissao_boleto # identificaco emissao                  1
          segmento_p << distribuicao_boleto # indentificacao entrega                1
          segmento_p << pagamento.numero_documento.to_s.rjust(15, '0') # uso exclusivo                         4
          segmento_p << pagamento.data_vencimento.strftime('%d%m%Y') # data de venc.                         8
          segmento_p << pagamento.formata_valor(15) # valor documento                       15
          segmento_p << ''.rjust(5, '0') # agencia cobradora                     5
          segmento_p << '0' # dv agencia cobradora                  1
          segmento_p << pagamento.especie_titulo # especie do titulo                     2
          segmento_p << aceite # aceite                                1
          segmento_p << pagamento.data_emissao.strftime('%d%m%Y') # data de emissao titulo                8
          segmento_p << '0' # cod. do juros                         1   *
          segmento_p << ''.rjust(8, '0') # data juros                            8   *
          segmento_p << ''.rjust(15, '0') # valor juros                           15  *
          segmento_p << pagamento.cod_desconto # cod. do desconto                      1
          segmento_p << pagamento.formata_data_desconto('%d%m%Y') # data desconto                         8
          segmento_p << pagamento.formata_valor_desconto(15) # valor desconto                        15
          segmento_p << pagamento.formata_valor_iof(15) # valor IOF                             15
          segmento_p << pagamento.formata_valor_abatimento(15) # valor abatimento                      15
          segmento_p << ''.rjust(25, ' ') # identificacao titulo empresa          25  *
          segmento_p << '1' # cod. para protesto                    1   *
          segmento_p << '00' # dias para protesto                    2   *
          segmento_p << '0' # cod. para baixa                       1   *
          segmento_p << '000' # dias para baixa                       2   *
          segmento_p << '09' # cod. da moeda                         2
          segmento_p << ''.rjust(10, '0') # uso exclusivo                         10
          segmento_p << ' ' # uso exclusivo                         1
          segmento_p
        end

        def complemento_p(pagamento)
          # CAMPO                   TAMANHO
          # conta corrente          12
          # digito conta            1
          # digito agencia/conta    1
          # ident. titulo no banco  20
          "#{conta_corrente.rjust(12, '0')}#{digito_conta} #{formata_nosso_numero(pagamento)}"
        end

        # Monta o registro trailer do lote
        #
        # @param nro_lote [Integer]
        #   numero do lote no arquivo (iterar a cada novo lote)
        #
        # @param nro_registros [Integer]
        #   numero de registros(linhas) no lote (contando header e trailer)
        #
        # @return [String]
        #
        def monta_trailer_lote(nro_lote, nro_registros)
          # CAMPO                                           # TAMANHO
          trailer_lote = ''
          # codigo banco                                    3
          trailer_lote << cod_banco
          # lote de servico                                 4
          trailer_lote << nro_lote.to_s.rjust(4, '0')
          # tipo de servico                                 1
          trailer_lote << '5'
          # uso exclusivo                                   9
          trailer_lote << ''.rjust(9, ' ')
          # qtde de registros lote                          6
          trailer_lote << nro_registros.to_s.rjust(6, '0')

          # qtde de Títulos em Cobrança Simples             6
          trailer_lote << pagamentos.count.to_s.rjust(6, '0')
          # Valor Total dos Títulos em Carteiras Simples    15 2
          trailer_lote << valor_total_titulos(17)
          # qtde de Títulos em Cobrança Vinculada           6
          trailer_lote << ''.rjust(6, '0')
          # Valor Total dos Títulos em Carteiras Vinculada  15 2
          trailer_lote << ''.rjust(17, '0')
          # qtde de Títulos em Cobrança Caucionada          6
          trailer_lote << ''.rjust(6, '0')
          # Valor Total dos Títulos em Carteiras Caucionada 15 2
          trailer_lote << ''.rjust(17, '0')
          # qtde de Títulos em Cobrança Descontada          6
          trailer_lote << ''.rjust(6, '0')
          # Valor Total dos Títulos em Carteiras Descontada 15 2
          trailer_lote << ''.rjust(17, '0')
          # Número do Aviso de Lançamento                   8
          trailer_lote << ''.rjust(8, ' ')

          # uso exclusivo                                   117
          trailer_lote << complemento_trailer
          trailer_lote
        end

        # Monta o registro trailer do arquivo
        #
        # @param nro_lotes [Integer]
        #   numero de lotes no arquivo
        # @param sequencial [Integer]
        #   numero de registros(linhas) no arquivo
        #
        # @return [String]
        #
        def monta_trailer_arquivo(nro_lotes, sequencial)
          # CAMPO                     TAMANHO
          # codigo banco                    3
          # lote de servico                 4
          # tipo de registro                1
          # uso FEBRABAN                    9
          # nro de lotes                    6
          # nro de registros(linhas)        6
          # qtde de Contas p/ Conc. (Lotes) 6
          # Uso FEBRABAN/CNAB               205
          "#{cod_banco}99999#{''.rjust(9, ' ')}#{nro_lotes.to_s.rjust(6, '0')}#{sequencial.to_s.rjust(6, '0')}#{''.rjust(6, '0')}#{''.rjust(205, ' ')}"
        end

        # Retorna o nosso numero
        #
        # @return [String]
        #
        # Nosso Número:
        #  - Se emissão a cargo do Cedente (vide planilha "Capa" deste arquivo):
        #       NumTitulo - 10 posições (1 a 10) Com DV
        #       Parcela - 02 posições (11 a 12) - "01" se parcela única
        #       Modalidade - 02 posições (13 a 14) - vide planilha "Capa" deste arquivo
        #       Tipo Formulário - 01 posição  (15 a 15):
        #            "1" -auto-copiativo
        #            "3" -auto-envelopável
        #            "4" -A4 sem envelopamento
        #            "6" -A4 sem envelopamento 3 vias
        #       Em branco - 05 posições (16 a 20)
        def formata_nosso_numero(pagamento)
          "#{pagamento.nosso_numero.to_s.rjust(10, '0')}#{pagamento.parcela.to_s.rjust(2, '0')}#{modalidade_carteira}#{tipo_formulario}#{''.to_s.rjust(5, ' ')}"
        end
      end
    end
  end
end
