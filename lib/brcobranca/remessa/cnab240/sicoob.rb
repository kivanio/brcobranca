# -*- encoding: utf-8 -*-
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

        attr_accessor :parcela
        #       Parcela - 02 posições (11 a 12) - "01" se parcela única

        attr_accessor :posto
        # Mantém a informação do posto de atendimento dentro da agência.

        validates_presence_of :modalidade_carteira, :tipo_formulario, :parcela, :convenio, message: 'não pode estar em branco.'
        # Remessa 400 - 8 digitos
        # Remessa 240 - 12 digitos
        validates_length_of :conta_corrente, maximum: 8, message: 'deve ter 8 dígitos.'
        validates_length_of :agencia, is: 4, message: 'deve ter 4 dígitos.'
        validates_length_of :modalidade_carteira, is: 2, message: 'deve ter 2 dígitos.'

        def initialize(campos = {})
          campos = { emissao_boleto: '2',
            distribuicao_boleto: '2',
            especie_titulo: '02',
            tipo_formulario: '4',
            parcela: '01',
            modalidade_carteira: '01',
            forma_cadastramento: '0',
            posto: '00'}.merge!(campos)
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

        def uso_exclusivo_banco
          ''.rjust(20, ' ')
        end

        def uso_exclusivo_empresa
          ''.rjust(20, ' ')
        end

        def digito_agencia
          # utilizando a agencia com 4 digitos
          # para calcular o digito
          agencia.modulo11(mapeamento: { 10 => '0' }).to_s
        end

        def digito_conta
          # utilizando a conta corrente com 5 digitos
          # para calcular o digito
          conta_corrente.modulo11(mapeamento: { 10 => '0' }).to_s
        end

        def dv_agencia_cobradora
          ' '
        end

        def codigo_convenio
          # CAMPO                TAMANHO
          # num. convenio        20 BRANCOS
          ''.rjust(20, ' ')
        end

        alias_method :convenio_lote, :codigo_convenio

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
          # CAMPO                               TAMANHO
          # Qt. Títulos em Cobrança Simples     6
          # Vl. Títulos em Carteira Simples     15 + 2 decimais
          # Qt. Títulos em Cobrança Vinculada   6
          # Vl. Títulos em Carteira Vinculada   15 + 2 decimais
          # Qt. Títulos em Cobrança Caucionada  6
          # Vl. Títulos em Carteira Caucionada  15 + 2 decimais
          # Qt. Títulos em Cobrança Descontada  6
          # Vl. Títulos em Carteira Descontada  15 + 2 decimais
          total_cobranca_simples    = "#{quantidade_titulos_cobranca}#{valor_titulos_carteira}"
          total_cobranca_vinculada  = "".rjust(23, "0")
          total_cobranca_caucionada = "".rjust(23, "0")
          total_cobranca_descontada = "".rjust(23, "0")

          "#{total_cobranca_simples}#{total_cobranca_vinculada}#{total_cobranca_caucionada}"\
            "#{total_cobranca_descontada}".ljust(217, ' ')
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
          # codigo banco              3
          # lote de servico           4
          # tipo de registro          1
          # uso FEBRABAN              9
          # nro de lotes              6
          # nro de registros(linhas)  6
          # uso FEBRABAN              211
          "#{cod_banco}99999#{''.rjust(9, ' ')}#{nro_lotes.to_s.rjust(6, '0')}#{sequencial.to_s.rjust(6, '0')}#{''.rjust(6, '0')}#{''.rjust(205, ' ')}"
        end

        def complemento_p(pagamento)
          # CAMPO                   TAMANHO
          # conta corrente          12
          # digito conta            1
          # digito agencia/conta    1
          # ident. titulo no banco  20
          "#{conta_corrente.rjust(12, '0')}#{digito_conta} #{formata_nosso_numero(pagamento.nosso_numero)}"
        end


        def monta_segmento_r(pagamento, nro_lote, sequencial)
          segmento_r = ''                                               # CAMPO                                TAMANHO
          segmento_r << cod_banco                                       # codigo banco                         3
          segmento_r << nro_lote.to_s.rjust(4, '0')                     # lote de servico                      4
          segmento_r << '3'                                             # lote de servico                      1
          segmento_r << sequencial.to_s.rjust(5, '0')                   # num. sequencial do registro no lote  5
          segmento_r << 'R'                                             # cod. segmento                        1
          segmento_r << ' '                                             # uso exclusivo                        1
          segmento_r << '01'                                            # cod. movimento remessa               2
          segmento_r << "0"                                             # cod. desconto 2                      1
          segmento_r << "".rjust(8,  '0')                               # data desconto 2                      8
          segmento_r << "".rjust(15,  '0')                              # valor desconto 2                     15
          segmento_r << "0"                                             # cod. desconto 3                      1
          segmento_r << "".rjust(8,  '0')                               # data desconto 3                      8
          segmento_r << "".rjust(15,  '0')                              # valor desconto 3                     15
          segmento_r << pagamento.codigo_multa                          # codigo multa                         1
          segmento_r << data_multa(pagamento)                           # data multa                           8
          segmento_r << pagamento.formata_percentual_multa(15)          # valor multa                          15
          segmento_r << ''.rjust(10, ' ')                               # info pagador                         10
          segmento_r << ''.rjust(40, ' ')                               # mensagem 3                           40
          segmento_r << ''.rjust(40, ' ')                               # mensagem 4                           40
          segmento_r << ''.rjust(20, ' ')                               # Exclusivo FEBRABAN                   20
          segmento_r << ''.rjust(8, '0')                                # Cod. Ocor do Pagador                 8
          segmento_r << ''.rjust(3, '0')                                # Cod. do Banco conta débito           3
          segmento_r << ''.rjust(5, '0')                                # Cod. da Agencia do débito            5
          segmento_r << ' '                                             # Cod. verificador da agencia          1
          segmento_r << ''.rjust(12, '0')                               # Conta corrente para débito           12
          segmento_r << ' '                                             # Cod. verificador da conta            1
          segmento_r << ' '                                             # Cod. verificador da Ag/Conta         1
          segmento_r << '0'                                             # Aviso débito automático              1
          segmento_r << ''.rjust(9, ' ')                                # Uso FEBRABAN                         9
          segmento_r
        end

        def data_multa(pagamento)
          return ''.rjust(8, '0') if pagamento.codigo_multa == '0'
          pagamento.data_vencimento.strftime('%d%m%Y')
        end

        # Retorna o nosso numero
        #
        # @return [String]
        #
        # Nosso Número:
        #  - Se emissão a cargo do Cedente (vide planilha "Capa" deste arquivo):
        #       NumTitulo - 10 posições (1 a 10)
        #       Parcela - 02 posições (11 a 12) - "01" se parcela única
        #       Modalidade - 02 posições (13 a 14) - vide planilha "Capa" deste arquivo
        #       Tipo Formulário - 01 posição  (15 a 15):
        #            "1" -auto-copiativo
        #            "3" -auto-envelopável
        #            "4" -A4 sem envelopamento
        #            "6" -A4 sem envelopamento 3 vias
        #       Em branco - 05 posições (16 a 20)
        def formata_nosso_numero(nosso_numero)
          "#{nosso_numero.to_s.rjust(10, '0')}#{parcela}#{modalidade_carteira}#{tipo_formulario}     "
        end

        def dias_baixa(pagamento)
          ''.rjust(3, ' ')
        end
      end
    end
  end
end
