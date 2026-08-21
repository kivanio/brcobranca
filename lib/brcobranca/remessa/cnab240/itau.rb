# frozen_string_literal: true

module Brcobranca
  module Remessa
    module Cnab240
      class Itau < Brcobranca::Remessa::Cnab240::Base
        validates_length_of :agencia, maximum: 4,
                                      message: "deve ter 4 dígitos."
        validates_length_of :conta_corrente, maximum: 5,
                                             message: "deve ter 5 dígitos."
        validates_length_of :carteira, maximum: 3,
                                       message: "deve ter 3 dígitos."

        def initialize(campos = {})
          # emissao_boleto/distribuicao_boleto/codigo_carteira/
          # forma_cadastramento nao fazem parte do layout do Segmento P do
          # Itau (ver #monta_segmento_p), mas precisam de um valor de 1
          # digito para passar nas validacoes genericas de Cnab240::Base.
          campos = { especie_titulo: "01",
                     emissao_boleto: "0",
                     distribuicao_boleto: "0" }.merge!(campos)
          super
        end

        def agencia=(valor)
          @agencia = valor.to_s.rjust(4, "0") if valor
        end

        def conta_corrente=(valor)
          @conta_corrente = valor.to_s.rjust(5, "0") if valor
        end

        def carteira=(valor)
          @carteira = valor.to_s.rjust(3, "0") if valor
        end

        def cod_banco
          "341"
        end

        def nome_banco
          "BANCO ITAU SA".ljust(30, " ")
        end

        def versao_layout_arquivo
          "040"
        end

        def versao_layout_lote
          "030"
        end

        def exclusivo_servico
          "00"
        end

        # Digito verificador de agencia/conta corrente.
        #
        # @return [String]
        def agencia_conta_corrente_dv
          Brcobranca::Util::Itau.agencia_conta_corrente_dv(
            agencia, conta_corrente
          ).to_s
        end

        # Digito verificador do nosso numero.
        #
        # Calculado sobre o nosso numero ja com 8 posicoes (mesmo valor
        # gravado no segmento P), e nao sobre o valor "cru" informado pelo
        # usuario - ver #monta_segmento_p e #formata_nosso_numero.
        #
        # @return [String]
        def nosso_numero_dv(pagamento)
          Brcobranca::Util::Itau.nosso_numero_dv(
            agencia, conta_corrente, carteira, formata_nosso_numero(pagamento)
          ).to_s
        end

        # Nosso numero com exatamente 8 posicoes.
        #
        # O nosso numero pode vir do chamador (ex.: sequencia interna do
        # Odoo) com mais de 8 digitos; nesse caso ficam os 8 ultimos
        # digitos (o mesmo criterio usado para interpretar o nosso numero
        # no arquivo de retorno), em vez de simplesmente preencher com
        # zeros a esquerda sem cortar o excedente.
        #
        # @return [String]
        def formata_nosso_numero(pagamento)
          pagamento.nosso_numero.to_s.rjust(8, "0")[-8..-1]
        end

        # Informacoes da conta corrente do cedente no header de lote.
        #
        # CAMPO         TAMANHO
        # zeros         1
        # agencia       4
        # brancos       1
        # zeros         7
        # conta corrente 5
        # brancos       1
        # DAC ag/conta  1
        #
        # @return [String]
        def info_conta
          zeros = "".rjust(7, "0")
          "0#{agencia} #{zeros}#{conta_corrente} #{agencia_conta_corrente_dv}"
        end

        # Sem uso de codigo de convenio pelo Itau neste layout (header arquivo)
        #
        # @return [String]
        def codigo_convenio
          "".rjust(20, " ")
        end

        # Sem uso de codigo de convenio pelo Itau neste layout (header lote)
        #
        # @return [String]
        def convenio_lote
          "".rjust(20, " ")
        end

        def uso_exclusivo_banco
          "".rjust(20, " ")
        end

        def uso_exclusivo_empresa
          "".rjust(20, " ")
        end

        # Complemento do header de arquivo
        #
        # @return [String]
        def complemento_header
          "#{''.rjust(14, ' ')}#{''.rjust(3, '0')}#{''.rjust(12, ' ')}"
        end

        # Complemento do trailer de lote
        #
        # @return [String]
        def complemento_trailer
          "".rjust(217, " ")
        end

        def dv_agencia_cobradora
          "0"
        end

        # Prazo para baixa com exatamente 2 posicoes.
        #
        # O valor padrao herdado de Brcobranca::Remessa::Pagamento e "000"
        # (3 digitos, dimensionado para o layout generico de outros bancos)
        # e nao e truncado por um rjust simples, o que descasa o segmento P
        # do Itau (campo de 2 digitos, posicoes 225-226) em 1 byte quando o
        # chamador nao informa esse campo explicitamente.
        #
        # @return [String]
        def dias_baixa(pagamento)
          pagamento.dias_baixa.to_s.rjust(2, "0")[-2..-1]
        end

        # Monta o registro segmento P do arquivo.
        #
        # Layout especifico do Itau (manual "Cobranca FEBRABAN 240", item
        # 3.1, Segmento P) - o campo "N. da carteira" (3 digitos, posicoes
        # 038-040) nao corresponde ao hook generico `codigo_carteira` da
        # classe base (1 digito), por isso o segmento e montado por inteiro.
        #
        # CAMPO                                 POSICAO  TAMANHO
        # codigo banco                          001-003  3
        # lote de servico                       004-007  4
        # tipo de registro                      008      1
        # num. sequencial do registro no lote   009-013  5
        # cod. segmento                         014      1
        # uso exclusivo                         015      1
        # cod. movimento remessa                016-017  2
        # zeros                                 018      1
        # agencia                               019-022  4
        # brancos                               023      1
        # zeros                                 024-030  7
        # conta corrente                        031-035  5
        # brancos                               036      1
        # DAC agencia/conta                     037      1
        # numero da carteira                    038-040  3
        # nosso numero                          041-048  8
        # DAC nosso numero                      049      1
        # brancos                               050-057  8
        # zeros                                 058-062  5
        # numero do documento                   063-072  10
        # brancos                               073-077  5
        # data de vencimento                    078-085  8
        # valor do titulo                       086-100  15
        # agencia cobradora                     101-105  5
        # DAC agencia cobradora                 106      1
        # especie do titulo                     107-108  2
        # aceite                                109      1
        # data de emissao do titulo             110-117  8
        # zeros                                 118      1
        # data base juros de mora               119-126  8
        # valor de mora por dia de atraso       127-141  15
        # zeros                                 142      1
        # data limite do 1o desconto            143-150  8
        # valor do 1o desconto                  151-165  15
        # valor do IOF                          166-180  15
        # valor do abatimento                   181-195  15
        # identificacao do titulo na empresa    196-220  25
        # codigo para negativacao/protesto      221      1
        # prazo para negativacao/protesto       222-223  2
        # codigo para baixa                     224      1
        # prazo para baixa                      225-226  2
        # zeros                                 227-239  13
        # brancos                               240      1
        #
        # @return [String]
        def monta_segmento_p(pagamento, nro_lote, sequencial)
          segmento_p = ""
          segmento_p += cod_banco
          segmento_p << nro_lote.to_s.rjust(4, "0")
          segmento_p << "3"
          segmento_p << sequencial.to_s.rjust(5, "0")
          segmento_p << "P"
          segmento_p << " "
          segmento_p << pagamento.identificacao_ocorrencia
          segmento_p << "0"
          segmento_p << agencia
          segmento_p << " "
          segmento_p << "".rjust(7, "0")
          segmento_p << conta_corrente
          segmento_p << " "
          segmento_p << agencia_conta_corrente_dv
          segmento_p << carteira
          segmento_p << formata_nosso_numero(pagamento)
          segmento_p << nosso_numero_dv(pagamento)
          segmento_p << "".rjust(8, " ")
          segmento_p << "".rjust(5, "0")
          segmento_p << pagamento.formata_documento_ou_numero(10, " ")
          segmento_p << "".rjust(5, " ")
          segmento_p << pagamento.data_vencimento.strftime("%d%m%Y")
          segmento_p << pagamento.formata_valor(15)
          segmento_p << "".rjust(5, "0")
          segmento_p << dv_agencia_cobradora
          segmento_p << especie_titulo
          segmento_p << aceite
          segmento_p << pagamento.data_emissao.strftime("%d%m%Y")
          segmento_p << "0"
          segmento_p << data_mora(pagamento)
          segmento_p << pagamento.formata_valor_mora(15)
          segmento_p << "0"
          segmento_p << pagamento.formata_data_desconto("%d%m%Y")
          segmento_p << pagamento.formata_valor_desconto(15)
          segmento_p << pagamento.formata_valor_iof(15)
          segmento_p << pagamento.formata_valor_abatimento(15)
          segmento_p << pagamento.formata_documento_ou_numero(25, " ")
          segmento_p << pagamento.codigo_protesto
          segmento_p << pagamento.dias_protesto.to_s.rjust(2, "0")
          segmento_p << codigo_baixa(pagamento)
          segmento_p << dias_baixa(pagamento)
          segmento_p << "".rjust(13, "0")
          segmento_p << " "
          segmento_p
        end

        # Monta o registro segmento Q do arquivo.
        #
        # Layout especifico do Itau - o nome do pagador ocupa 30 posicoes
        # (com 10 posicoes em branco a seguir) e o nome do sacador/avalista
        # ocupa 30 posicoes, diferente do padrao generico de 40 posicoes sem
        # espacamento usado pela classe base.
        #
        # CAMPO                                 POSICAO  TAMANHO
        # codigo banco                          001-003  3
        # lote de servico                       004-007  4
        # tipo de registro                      008      1
        # num. sequencial do registro no lote   009-013  5
        # cod. segmento                         014      1
        # brancos                               015      1
        # cod. movimento remessa                016-017  2
        # tipo insc. pagador                    018      1
        # documento pagador                     019-033  15
        # nome pagador                          034-063  30
        # brancos                               064-073  10
        # logradouro                            074-113  40
        # bairro                                114-128  15
        # cep                                   129-133  5
        # sufixo cep                            134-136  3
        # cidade                                137-151  15
        # uf                                    152-153  2
        # tipo insc. sacador/avalista           154      1
        # documento sacador/avalista            155-169  15
        # nome sacador/avalista                 170-199  30
        # brancos                               200-209  10
        # zeros                                 210-212  3
        # brancos                               213-240  28
        #
        # @return [String]
        def monta_segmento_q(pagamento, nro_lote, sequencial)
          segmento_q = ""
          segmento_q += cod_banco
          segmento_q << nro_lote.to_s.rjust(4, "0")
          segmento_q << "3"
          segmento_q << sequencial.to_s.rjust(5, "0")
          segmento_q << "Q"
          segmento_q << " "
          segmento_q << pagamento.identificacao_ocorrencia
          segmento_q << pagamento.identificacao_sacado(false)
          segmento_q << pagamento.documento_sacado.to_s.rjust(15, "0")
          segmento_q << pagamento.nome_sacado.format_size(30)
          segmento_q << "".rjust(10, " ")
          segmento_q << pagamento.endereco_sacado.format_size(40)
          segmento_q << pagamento.bairro_sacado.format_size(15)
          segmento_q << pagamento.cep_sacado[0..4]
          segmento_q << pagamento.cep_sacado[5..7]
          segmento_q << pagamento.cidade_sacado.format_size(15)
          segmento_q << pagamento.uf_sacado
          segmento_q << pagamento.identificacao_avalista(false)
          segmento_q << pagamento.documento_avalista.to_s.rjust(15, "0")
          segmento_q << pagamento.nome_avalista.format_size(30)
          segmento_q << "".rjust(10, " ")
          segmento_q << "".rjust(3, "0")
          segmento_q << "".rjust(28, " ")
          segmento_q
        end
      end
    end
  end
end
