# frozen_string_literal: true

module Brcobranca
  module Remessa
    module Cnab240
      class Santander < Brcobranca::Remessa::Cnab240::Base

        # Código de Transmissão
        attr_accessor :codigo_transmissao
        # Dígito da Agência
        attr_accessor :digito_agencia

        validates_presence_of :codigo_transmissao, :digito_agencia, :digito_conta, message: 'não pode estar em branco.'

        validates_length_of :codigo_transmissao, maximum: 15, message: 'deve ter no máximo 15 dígitos.'
        validates_length_of :agencia, maximum: 4, message: 'deve ter 4 dígitos.'
        validates_length_of :digito_agencia, maximum: 1, message: 'deve ter 1 dígito.'
        validates_length_of :conta_corrente, maximum: 9, message: 'deve ter 9 dígitos.'
        validates_length_of :digito_conta, maximum: 1, message: 'deve ter 1 dígito.'

        def initialize(campos = {})
          campos = {  emissao_boleto: ' ', distribuicao_boleto: ' ',
                      especie_titulo: '02', tipo_documento: '2' }.merge!(campos)
          super(campos)
        end

        def codigo_transmissao=(valor)
          @codigo_transmissao = valor.to_s.strip.rjust(15, '0') if valor
        end

        def complemento_header
          ''.rjust(29, ' ')
        end

        def complemento_trailer
          ''.rjust(217, ' ')
        end

        def complemento_p(pagamento)
          complemento_p = ''
          complemento_p += conta_corrente.rjust(9, '0')
          complemento_p << digito_conta.to_s
          complemento_p << conta_corrente.rjust(9, '0')
          complemento_p << digito_conta.to_s
          complemento_p << '  '
          complemento_p << identificador_titulo(pagamento.nosso_numero)
          complemento_p
        end

        def complemento_r
          ''.rjust(61, ' ')
        end

        def versao_layout_arquivo
          '040'
        end

        def versao_layout_lote
          '030'
        end

        def convenio_lote
          identificacao_conta = ''
          identificacao_conta += ''.rjust(20, ' ')
          identificacao_conta << codigo_transmissao
          identificacao_conta << ''.rjust(5, ' ')
          identificacao_conta
        end

        def nome_banco
          'BANCO SANTANDER'.ljust(30, ' ')
        end

        def cod_banco
          '033'
        end

        def info_conta
          ''
        end

        def codigo_convenio
          identificacao_conta = ''
          identificacao_conta += codigo_transmissao
          identificacao_conta << ''.rjust(25, ' ')
          identificacao_conta
        end

        def identificador_titulo(nosso_numero)
          nosso_numero_dv = nosso_numero.modulo11(
            multiplicador: (2..9).to_a,
            mapeamento: { 10 => 0, 11 => 0 }
          ) { |total| 11 - (total % 11) }

          "#{nosso_numero}#{nosso_numero_dv}".rjust(13, '0')
        end

        def formata_documento_ou_numero(pagamento, tamanho = 25, caracter = ' ')
          doc = pagamento.documento_ou_numero.to_s.gsub(/[^0-9A-Za-z ]/, '')
          doc.ljust(tamanho, caracter)[0...tamanho]
        end

        def densidade_gravacao
          ''.rjust(5, ' ')
        end

        def uso_exclusivo_banco
          ''.rjust(20, ' ')
        end

        def uso_exclusivo_empresa
          ''.rjust(20, ' ')
        end

        def hora_geracao
          ''.rjust(6, ' ')
        end

        def dv_agencia_cobradora
          ''.rjust(1, ' ')
        end

        def monta_header_arquivo
          header_arquivo = ''                                   # CAMPO                         TAMANHO
          header_arquivo += cod_banco                           # codigo do banco               3
          header_arquivo << '0000'                              # lote do servico               4
          header_arquivo << '0'                                 # tipo de registro              1
          header_arquivo << ''.rjust(8, ' ')                    # uso exclusivo FEBRABAN        9
          header_arquivo << Brcobranca::Util::Empresa.new(documento_cedente, false).tipo # tipo inscricao                1
          header_arquivo << documento_cedente.to_s.rjust(15, '0') # numero de inscricao         15
          header_arquivo << codigo_convenio                     # codigo do convenio no banco   20
          header_arquivo << info_conta                          # informacoes da conta          20
          header_arquivo << empresa_mae.format_size(30)         # nome da empresa               30
          header_arquivo << nome_banco.format_size(30)          # nome do banco                 30
          header_arquivo << ''.rjust(10, ' ')                   # uso exclusivo FEBRABAN        10
          header_arquivo << '1'                                 # codigo remessa                1
          header_arquivo << data_geracao                        # data geracao                  8
          header_arquivo << hora_geracao                        # hora geracao                  6
          header_arquivo << sequencial_remessa.to_s.rjust(6, '0') # numero seq. arquivo         6
          header_arquivo << versao_layout_arquivo               # num. versao arquivo           3
          header_arquivo << densidade_gravacao                  # densidade gravacao            5
          header_arquivo << uso_exclusivo_banco                 # uso exclusivo                 20
          header_arquivo << uso_exclusivo_empresa               # uso exclusivo                 20
          header_arquivo << complemento_header                  # complemento do arquivo        29
          header_arquivo
        end

        def monta_segmento_p(pagamento, nro_lote, sequencial)
          segmento_p = ''
          #                                                             # DESCRICAO                             TAMANHO
          segmento_p += cod_banco # codigo banco                          3
          segmento_p << nro_lote.to_s.rjust(4, '0')                     # lote de servico                       4
          segmento_p << '3'                                             # tipo de registro                      1
          segmento_p << sequencial.to_s.rjust(5, '0')                   # num. sequencial do registro no lote   5
          segmento_p << 'P'                                             # cod. segmento                         1
          segmento_p << ' '                                             # uso exclusivo                         1
          segmento_p << pagamento.identificacao_ocorrencia              # cod. movimento remessa                2
          segmento_p << agencia.to_s.rjust(4, '0')                      # agencia                               4
          segmento_p << digito_agencia.to_s                             # dv agencia                            1
          segmento_p << complemento_p(pagamento)                        # informacoes da conta                  34
          segmento_p << codigo_carteira                                 # codigo da carteira                    1
          segmento_p << forma_cadastramento                             # forma de cadastro do titulo           1
          segmento_p << tipo_documento                                  # tipo de documento                     1
          segmento_p << emissao_boleto                                  # identificaco emissao                  1
          segmento_p << distribuicao_boleto                             # indentificacao entrega                1
          segmento_p << formata_documento_ou_numero(pagamento, 15)      # uso exclusivo                         4
          segmento_p << pagamento.data_vencimento.strftime('%d%m%Y')    # data de venc.                         8
          segmento_p << pagamento.formata_valor(15)                     # valor documento                       15
          segmento_p << ''.rjust(5, '0')                                # agencia cobradora                     5
          segmento_p << dv_agencia_cobradora                            # dv agencia cobradora                  1
          segmento_p << especie_titulo                                  # especie do titulo                     2
          segmento_p << aceite                                          # aceite                                1
          segmento_p << pagamento.data_emissao.strftime('%d%m%Y')       # data de emissao titulo                8
          segmento_p << pagamento.tipo_mora                             # cod. do mora                          1
          segmento_p << data_mora(pagamento)                            # data mora                             8
          segmento_p << pagamento.formata_valor_mora(15)                # valor mora                            15
          segmento_p << codigo_desconto(pagamento)                      # cod. do desconto                      1
          segmento_p << pagamento.formata_data_desconto('%d%m%Y')       # data desconto                         8
          segmento_p << pagamento.formata_valor_desconto(15)            # valor desconto                        15
          segmento_p << pagamento.formata_valor_iof(15)                 # valor IOF                             15
          segmento_p << pagamento.formata_valor_abatimento(15)          # valor abatimento                      15
          segmento_p << formata_documento_ou_numero(pagamento)          # identificacao titulo empresa          25
          segmento_p << pagamento.codigo_protesto                       # cod. para protesto                    1
          segmento_p << pagamento.dias_protesto.to_s.rjust(2, '0')      # dias para protesto                    2
          segmento_p << '3'                                             # cod. para baixa                       1
          segmento_p << '0'                                             # zero fixo                             1
          segmento_p << '00'                                            # dias para baixa                       2
          segmento_p << '00'                                            # cod. da moeda                         2
          segmento_p << ''.rjust(11, ' ')                               # uso exclusivo                         11
          segmento_p
        end

        def monta_segmento_q(pagamento, nro_lote, sequencial)
          segmento_q = ''                                               # CAMPO                                TAMANHO
          segmento_q += cod_banco                                       # codigo banco                         3
          segmento_q << nro_lote.to_s.rjust(4, '0')                     # lote de servico                      4
          segmento_q << '3'                                             # tipo de registro                     1
          segmento_q << sequencial.to_s.rjust(5, '0')                   # num. sequencial do registro no lote  5
          segmento_q << 'Q'                                             # cod. segmento                        1
          segmento_q << ' '                                             # uso exclusivo                        1
          segmento_q << pagamento.identificacao_ocorrencia              # cod. movimento remessa               2
          segmento_q << pagamento.identificacao_sacado(false)           # tipo insc. sacado                    1
          segmento_q << pagamento.documento_sacado.to_s.rjust(15, '0')  # documento sacado                     14
          segmento_q << pagamento.nome_sacado.format_size(40)           # nome cliente                         40
          segmento_q << pagamento.endereco_sacado.format_size(40)       # endereco cliente                     40
          segmento_q << pagamento.bairro_sacado.format_size(15)         # bairro                               15
          segmento_q << pagamento.cep_sacado[0..4]                      # cep                                  5
          segmento_q << pagamento.cep_sacado[5..7]                      # sufixo cep                           3
          segmento_q << pagamento.cidade_sacado.format_size(15)         # cidade                               15
          segmento_q << pagamento.uf_sacado                             # uf                                   2
          segmento_q << pagamento.identificacao_avalista(false)         # identificacao do sacador             1
          segmento_q << pagamento.documento_avalista.to_s.rjust(15, '0') # documento sacador                    15
          segmento_q << pagamento.nome_avalista.format_size(40)         # nome avalista                        40
          segmento_q << ''.rjust(12, '0')                               # Reservado (uso Branco)               12
          segmento_q << ''.rjust(19, ' ')                               # Reservado (uso Branco)               19
          segmento_q
        end

      end
    end
  end
end
