# -*- encoding: utf-8 -*-
module Brcobranca
  module Remessa
    module Cnab240
      class BancoBrasil < Brcobranca::Remessa::Cnab240::Base
        # variacao da carteira
        attr_accessor :variacao
        # identificacao da emissao do boleto (attr na classe base)
        #   campo nao tratado pelo sistema do Banco do Brasil
        # identificacao da distribuicao do boleto (attr na classe base)
        #   campo nao tratado pelo sistema do Banco do Brasil

        validates_presence_of :carteira, :variacao, message: 'não pode estar em branco.'
        validates_presence_of :convenio, message: 'não pode estar em branco.'
        validates_length_of :conta_corrente, maximum: 12, message: 'deve ter 12 dígitos.'
        validates_length_of :agencia, maximum: 5, message: 'deve ter 5 dígitos.'
        validates_length_of :carteira, is: 2, message: 'deve ter 2 dígitos.'
        validates_length_of :variacao, is: 3, message: 'deve ter 3 dígitos.'
        validates_length_of :convenio, in: 4..7, message: 'deve ter de 4 a 7 dígitos.'

        def initialize(campos = {})
          campos = { emissao_boleto: '0',
            distribuicao_boleto: '0',
            especie_titulo: '02',
            codigo_baixa: '00',
            codigo_carteira: '7',}.merge!(campos)
          super(campos)
        end

        def cod_banco
          '001'
        end

        def nome_banco
          'BANCO DO BRASIL S.A.'.ljust(30, ' ')
        end

        def versao_layout_arquivo
          '083'
        end

        def versao_layout_lote
          '042'
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
          # num. convenio        9
          # cobranca cedente     4
          # carteira             2
          # variacao carteira    3
          # campo reservado      2
          "#{convenio.rjust(9, '0')}0014#{carteira}#{variacao}  "
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
          ''.rjust(217, '0')
        end

        def complemento_p(pagamento)
          # CAMPO                   TAMANHO
          # conta corrente          12
          # digito conta            1
          # digito agencia/conta    1
          # ident. titulo no banco  20
          "#{conta_corrente.rjust(12, '0')}#{digito_conta} #{identificador_titulo(pagamento.nosso_numero)}"
        end

        # Retorna o nosso numero mais o digito verificador
        #
        # @return [String]
        #
        def formata_nosso_numero(nosso_numero)
          quantidade = case convenio.to_s.size
                         # convenio de 4 posicoes com nosso numero de 7
                       when 4 then
                         7
                         # convenio de 6 posicoes com nosso numero de 5
                       when 6 then
                         5
                         # convenio de 7 posicoes com nosso numero de 10
                       when 7 then
                         10
                       else
                         raise Brcobranca::NaoImplementado, 'Tipo de convênio não implementado.'
                       end
          nosso_numero = nosso_numero.to_s.rjust(quantidade, '0')

          # calcula o digito do nosso numero (menos para quando nosso numero tiver 10 posicoes)
          digito = "#{convenio}#{nosso_numero}".modulo11(mapeamento: { 10 => 'X' }) unless quantidade == 10
          "#{nosso_numero}#{digito}"
        end

        def identificador_titulo(nosso_numero)
          "#{convenio}#{formata_nosso_numero(nosso_numero)}".ljust(20, ' ')
        end

        # Monta o registro segmento P do arquivo
        #
        # @param pagamento [Brcobranca::Remessa::Pagamento]
        #   objeto contendo os detalhes do boleto (valor, vencimento, sacado, etc)
        # @param nro_lote [Integer]
        #   numero do lote que o segmento esta inserido
        # @param sequencial [Integer]
        #   numero sequencial do registro no lote
        #
        # @return [String]
        #
        def monta_segmento_p(pagamento, nro_lote, sequencial)
          # campos com * na frente nao foram implementados
          #                                                             # DESCRICAO                             TAMANHO
          segmento_p = cod_banco                                        # codigo banco                          3
          segmento_p << nro_lote.to_s.rjust(4, '0')                     # lote de servico                       4
          segmento_p << '3'                                             # tipo de registro                      1
          segmento_p << sequencial.to_s.rjust(5, '0')                   # num. sequencial do registro no lote   5
          segmento_p << 'P'                                             # cod. segmento                         1
          segmento_p << ' '                                             # uso exclusivo                         1
          # Códigos de Movimento para Remessa tratados pelo Banco do Brasil:
          # 01 – Entrada de títulos,
          # 02 – Pedido de baixa,
          # 04 – Concessão de Abatimento,
          # 05 – Cancelamento de Abatimento,
          # 06 – Alteração de Vencimento,
          # 07 – Concessão de Desconto,
          # 08 – Cancelamento de Desconto,
          # 09 – Protestar,
          # 10 – Cancela/Sustação da Instrução de protesto,
          # 30 – Recusa da Alegação do Sacado,
          # 31 – Alteração de Outros Dados,
          # 40 – Alteração de Modalidade.
          segmento_p << pagamento.identificacao_ocorrencia              # cod. movimento remessa                2
          segmento_p << agencia.to_s.rjust(5, '0')                      # agencia                               5
          segmento_p << digito_agencia.to_s                             # dv agencia                            1
          segmento_p << complemento_p(pagamento)                        # informacoes da conta                  34
          # Informar:
          # 1 – para carteira 11/12 na modalidade Simples;
          # 2 ou 3 – para carteira 11/17 modalidade Vinculada/Caucionada e carteira 31;
          # 4 – para carteira 11/17 modalidade Descontada e carteira 51;
          # e 7 – para carteira 17 modalidade Simples.
          segmento_p << codigo_carteira                                 # codigo da carteira                    1
          segmento_p << forma_cadastramento                             # forma de cadastro do titulo           1
          segmento_p << tipo_documento                                  # tipo de documento                     1
          segmento_p << emissao_boleto                                  # identificaco emissao                  1
          segmento_p << distribuicao_boleto                             # indentificacao entrega                1
          segmento_p << numero(pagamento)                               # uso exclusivo                         15
          segmento_p << pagamento.data_vencimento.strftime('%d%m%Y')    # data de venc.                         8
          segmento_p << pagamento.formata_valor(15)                     # valor documento                       15
          segmento_p << ''.rjust(5, '0')                                # agencia cobradora                     5
          segmento_p << ' '                                             # dv agencia cobradora                  1
          # Para carteira 11 e 17 modalidade Simples, pode ser usado:
          # 01 – Cheque, 02 – Duplicata Mercantil,
          # 04 – Duplicata de Serviço,
          # 06 – Duplicata Rural,
          # 07 – Letra de Câmbio,
          # 12 – Nota Promissória,
          # 17 - Recibo,
          # 19 – Nota de Debito,
          # 26 – Warrant,
          # 27 – Dívida Ativa de Estado,
          # 28 – Divida Ativa de Município e
          # 29 – Dívida Ativa União.
          # Para carteira 12 (moeda variável) pode ser usado:
          # 02 – Duplicata Mercantil,
          # 04 – Duplicata de Serviço,
          # 07 – Letra de Câmbio,
          # 12 – Nota Promissória,
          # 17 – Recibo e
          # 19 – Nota de Débito.
          # Para carteira 15 (prêmio de seguro) pode ser usado:
          # 16 – Nota de Seguro e
          # 20 – Apólice de Seguro.
          # Para carteira 11/17 modalidade Vinculada e carteira 31, pode ser usado:
          # 02 – Duplicata Mercantil e
          # 04 – Duplicata de Serviço.
          # Para carteira 11/17 modalidade Descontada e carteira 51, pode ser usado:
          # 02 – Duplicata Mercantil,
          # 04 – Duplicata de Serviço, e
          # 07 – Letra de Câmbio.
          # Obs.: O Banco do Brasil encaminha para protesto os seguintes títulos:
          # Duplicata Mercantil, Rural e de Serviço, Letra de Câmbio, e
          # Certidão de Dívida Ativa da União, dos Estados e do Município.
          segmento_p << especie_titulo                                  # especie do titulo                     2
          segmento_p << aceite                                          # aceite                                1
          segmento_p << pagamento.data_emissao.strftime('%d%m%Y')       # data de emissao titulo                8
          segmento_p << pagamento.tipo_mora                             # cod. do juros                         1
          segmento_p << data_mora(pagamento)                            # data juros                            8
          segmento_p << pagamento.formata_valor_mora(15)                # valor juros                           15
          segmento_p << pagamento.cod_desconto                          # cod. do desconto                      1
          segmento_p << pagamento.formata_data_desconto('%d%m%Y')       # data desconto                         8
          segmento_p << pagamento.formata_valor_desconto(15)            # valor desconto                        15
          segmento_p << pagamento.formata_valor_iof(15)                 # valor IOF                             15
          segmento_p << pagamento.formata_valor_abatimento(15)          # valor abatimento                      15
          segmento_p << identificacao_titulo_empresa(pagamento)         # identificacao documento empresa       25

          # O Banco do Brasil trata somente os códigos
          # '1' – Protestar dias corridos,
          # '2' – Protestar dias úteis, e
          # '3' – Não protestar.
          # No caso de carteira 31 ou carteira 11/17 modalidade Vinculada,
          # se não informado nenhum código,
          # o sistema assume automaticamente Protesto em 3 dias úteis.
          segmento_p << pagamento.codigo_protesto                       # cod. para protesto                    1
          # Preencher de acordo com o código informado na posição 221.
          # Para código '1' – é possível, de 6 a 29 dias, 35o, 40o, dia corrido.
          # Para código '2' – é possível, 3o, 4o ou 5o dia útil.
          # Para código '3' preencher com Zeros.
          segmento_p << pagamento.dias_protesto.to_s.rjust(2, '0')      # dias para protesto                    2
          segmento_p << '0'                                             # cod. para baixa                       1   *'1' = Protestar Dias Corridos, '2' = Protestar Dias Úteis, '3' = Não Protestar
          segmento_p << '000'                                           # dias para baixa                       2   *
          segmento_p << '09'                                            # cod. da moeda                         2
          segmento_p << ''.rjust(10, '0')                               # uso exclusivo                         10
          segmento_p << ' '                                             # uso exclusivo                         1
          segmento_p
        end
      end
    end
  end
end
