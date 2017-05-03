# -*- encoding: utf-8 -*-
#
module Brcobranca
  module Remessa
    module Cnab400
      class Bradesco < Brcobranca::Remessa::Cnab400::Base
        # codigo da empresa (informado pelo Bradesco no cadastramento)
        attr_accessor :tipo_registro
        attr_accessor :debito_automatico
        attr_accessor :coobrigacao
        attr_accessor :caracteristica_especial
        attr_accessor :modalidade_operacao
          # Mod  Descrição
          # 0301 desconto de duplicatas
          # 0302 desconto de cheques
          # 0303 antecipação de fatura de cartão de crédito
          # 0398 outros direitos creditórios descontados
          # 0399 outros títulos descontados
        attr_accessor :natureza_operacao
          # Domínio Descrição
          # 02      Operações adquiridas em negociação com pessoa integrante do SFN sem retenção substancial de risco e de benefícios ou de controle pelo interveniente ou cedente
          # 03      Operações adquiridas em negociação com pessoa não integrante do SFN sem retenção substancial de risco e de benefícios ou de controle pelo interveniente ou cedente
          # 04      Operações adquiridas em negociação com pessoa integrante do SFN com retenção substancial de risco e de benefícios ou de controle pelo interveniente ou cedente
        attr_accessor :origem_recurso
          # Recursos livres
          # Descrição Mod Descrição
          # 0101      não liberados
          # 0102      repasses do exterior
          # 0199      outros
          #
          # Recursos direcionados
          # Descrição Mod Descrição
          # 0201      não liberados
          # 0202      BNDES - Banco Nacional de Desenvolvimento Econômico e Social
          # 0203      Finame - Agência Especial de Financiamento Industrial
          # 0204      FCO - Fundo Constitucional do Centro Oeste
          # 0205      FNE - Fundo Constitucional do Nordeste
          # 0206      FNO - Fundo Constitucional do Norte
          # 0207      fundos estaduais ou distritais
          # 0208      recursos captados em depósitos de poupança pelas entidades integrantes do SBPE destinados a operações de financiamento imobiliário
          # 0209      financiamentos concedidos ao amparo de recursos controlados do crédito rural
          # 0210      repasses de organismos multilaterais no exterior
          # 0211      outros repasses do exterior
          # 0212      fundos ou programas especiais do governo federal
          # 0213      FGTS – Fundo de Garantia do Tempo de Serviço
          # 0299      outros
        attr_accessor :classe_risco_operacao
          # Domínio Descrição
          # AA      Classificação de risco AA
          # A       Classificação de risco A
          # B       Classificação de risco B
          # C       Classificação de risco C
          # D       Classificação de risco D
          # E       Classificação de risco E
          # F       Classificação de risco F
          # G       Classificação de risco G
          # H       Classificação de risco H
          # HH      Classificação de risco HH - créditos baixados como prejuízo

        attr_accessor :n_controle_participante
        attr_accessor :numero_banco
        attr_accessor :nosso_numero
        attr_accessor :nosso_numero_dv
        attr_accessor :identificacao_emite_papeleta_debito_automatico
        attr_accessor :valor_pago
        attr_accessor :condicao_emissao
        attr_accessor :data_liquidacao
        attr_accessor :identificacao_operacao
        attr_accessor :indicador_rateio_credito
        attr_accessor :enderecamento_debito_automatico
        attr_accessor :identificacao_ocorrencia
        attr_accessor :n_do_documento
        attr_accessor :data_vencimento_titulo
        attr_accessor :valor_titulo
        attr_accessor :banco_cobranca
        attr_accessor :agencia_depositaria
        attr_accessor :especie_titulo
          # 01 - Duplicata
          # 02 - Nota Promissória
          # 06 - Nota Promissória Física
          # 12 - Duplicata de Serviço
          # 14 - Duplicata de Serviço Física
          # 51 - Cheque
          # 60 - Contrato
          # 61 - Contrato Físico
          # 65 - Fatura de Cartão Credito
        attr_accessor :identificacao
        attr_accessor :data_emissao_titulo
        attr_accessor :instrucao_1
        attr_accessor :instrucao_2
        attr_accessor :codigo_de_inscricao_cedente
        attr_accessor :numero_termo_cessao
        attr_accessor :valor_aquisicao
        attr_accessor :valor_abatimento
        attr_accessor :codigo_de_inscricao_sacado
        attr_accessor :numero_de_inscricao
        attr_accessor :nome_sacado
        attr_accessor :endereco_completo
        attr_accessor :n_nota_fiscal
        attr_accessor :n_serie_nota_fiscal
        attr_accessor :cep
        attr_accessor :cedente
        attr_accessor :nome_Cedente
        attr_accessor :numero_de_inscricao_cedente
        attr_accessor :chave_nota
        attr_accessor :sequencial

        validates_length_of :tipo_registro               , maximum: 1,  message: "deve no máximo ter 1 dígitos"
        validates_length_of :coobrigacao                 , maximum: 2,  message: "deve no máximo ter 2 dígitos"
        validates_length_of :n_controle_participante     , maximum: 25, message: "deve no máximo ter 25 dígitos"
        validates_length_of :numero_banco                , maximum: 3,  message: "deve no máximo ter 3 dígitos"
        validates_length_of :data_liquidacao             , maximum: 6,  message: "deve no máximo ter 6 dígitos"
        validates_length_of :identificacao_ocorrencia    , maximum: 2,  message: "deve no máximo ter 2 dígitos"
        validates_length_of :n_do_documento              , maximum: 10, message: "deve no máximo ter 10 dígitos"
        validates_length_of :data_vencimento_titulo      , maximum: 6,  message: "deve no máximo ter 6 dígitos"
        validates_length_of :valor_titulo                , maximum: 13, message: "deve no máximo ter 13 dígitos"
        validates_length_of :especie_titulo              , maximum: 2,  message: "deve no máximo ter 2 dígitos"
        validates_length_of :data_emissao_titulo         , maximum: 6,  message: "deve no máximo ter 6 dígitos"
        validates_length_of :codigo_de_inscricao_cedente , maximum: 2,  message: "deve no máximo ter 2 dígitos"
        validates_length_of :numero_termo_cessao         , maximum: 19, message: "deve no máximo ter 19 dígitos"
        validates_length_of :valor_aquisicao             , maximum: 13, message: "deve no máximo ter 13 dígitos"
        validates_length_of :codigo_de_inscricao_sacado  , maximum: 2,  message: "deve no máximo ter 2 dígitos"
        validates_length_of :numero_de_inscricao         , maximum: 14, message: "deve no máximo ter 14 dígitos"
        validates_length_of :nome_sacado                 , maximum: 40, message: "deve no máximo ter 40 dígitos"
        validates_length_of :endereco_completo           , maximum: 40, message: "deve no máximo ter 40 dígitos"
        validates_length_of :n_nota_fiscal               , maximum: 9,  message: "deve no máximo ter 9 dígitos"
        validates_length_of :cep                         , maximum: 8,  message: "deve no máximo ter 8 dígitos"
        validates_length_of :cedente                     , maximum: 60, message: "deve no máximo ter 60 dígitos"
        validates_length_of :nome_Cedente                , maximum: 46, message: "deve no máximo ter 46 dígitos"
        validates_length_of :numero_de_inscricao_cedente , maximum: 14, message: "deve no máximo ter 14 dígitos"
        validates_length_of :chave_nota                  , maximum: 44, message: "deve no máximo ter 44 dígitos"
        validates_length_of :sequencial                  , maximum: 6,  message: "deve no máximo ter 6 dígitos"


        validates_presence_of
          :tipo_registro,
          :coobrigacao,
          :n_controle_participante,
          :numero_banco,
          :data_liquidacao,
          :identificacao_ocorrencia,
          :n_do_documento,
          :data_vencimento_titulo,
          :valor_titulo,
          :especie_titulo,
          :data_emissao_titulo,
          :codigo_de_inscricao_cedente,
          :numero_termo_cessao,
          :valor_aquisicao,
          :codigo_de_inscricao_sacado,
          :numero_de_inscricao,
          :nome_sacado,
          :endereco_completo,
          :n_nota_fiscal,
          :cep,
          :cedente,
          :nome_Cedente,
          :numero_de_inscricao_cedente,
          :chave_nota,
          :sequencial
          , message: 'não pode estar em branco.'

        def initialize(campos = {})
          campos = {
            tipo_registro = "1",
            coobrigacao = "01",
            numero_banco = "000",
            especie_titulo = "01",
            codigo_de_inscricao_cedente = "02",
            codigo_de_inscricao_sacado = "02",
            caracteristica_especial = "35", operações cedidas nos termos da resolução 3.533/08.
            modalidade_operacao = "0301", # esta dentro de "Direitos creditórios descontados",todas as remessas tem a mesma operação "Direitos creditórios descontados"?
            natureza_operacao = "02", # Operações adquiridas em negociação com pessoa integrante do SFN sem retenção substancial de risco e de benefícios ou de controle pelo interveniente ou cedente
            origem_recurso = "0199", # outros
            classe_risco_operacao = "AA", # Classificação de risco AA
          }.merge!(campos)
          super(campos)
        end

        def gera_arquivo
          raise Brcobranca::RemessaInvalida, self unless valid?

          # contador de registros no arquivo
          contador = 1
          ret = [monta_header]
          pagamentos.each do |pagamento|
            contador += 1
            ret << monta_detalhe(pagamento, contador)
          end
          ret << monta_trailer(contador + 1)

          remittance = ret.join("\n").to_ascii.upcase
          remittance << "\n"

          remittance.encode(remittance.encoding, universal_newline: true).encode(remittance.encoding, crlf_newline: true)
        end

        def agencia=(valor)
          @agencia = valor.to_s.rjust(5, '0') if valor
        end

        def conta_corrente=(valor)
          @conta_corrente = valor.to_s.rjust(7, '0') if valor
        end

        def codigo_empresa=(valor)
          @codigo_empresa = valor.to_s.rjust(20, '0') if valor
        end

        def sequencial_remessa=(valor)
          @sequencial_remessa = valor.to_s.rjust(7, '0') if valor
        end

        def info_conta
          codigo_empresa
        end

        def cod_banco
          '611'
        end

        def nome_banco
          'PAULISTA S.A.'.ljust(15, ' ')
        end

        def complemento
          "#{''.rjust(8, ' ')}MX#{sequencial_remessa}#{''.rjust(321, ' ')}"
        end

        def identificacao_empresa
          # identificacao da empresa no banco
          identificacao = '0'                            # vazio                       [1]
          identificacao << carteira.to_s.rjust(3, '0')   # carteira                    [3]
          identificacao << agencia                       # codigo da agencia (sem dv)  [5]
          identificacao << conta_corrente                # codigo da conta             [7]
          identificacao << digito_conta                  # digito da conta             [1]
        end

        def digito_nosso_numero(nosso_numero)
          "#{carteira}#{nosso_numero.to_s.rjust(11, '0')}".modulo11(
            multiplicador: [2, 3, 4, 5, 6, 7],
            mapeamento: { 10 => 'P', 11 => 0 }
          ) { |total| 11 - (total % 11) }
        end

        # Formata o endereco do sacado
        # de acordo com os caracteres disponiveis (40)
        # concatenando o endereco, cidade e uf
        #
        def formata_endereco_sacado(pgto)
          endereco = "#{pgto.endereco_sacado}, #{pgto.cidade_sacado}/#{pgto.uf_sacado}"
          return endereco.ljust(40, ' ') if endereco.size <= 40
          "#{pgto.endereco_sacado[0..19]} #{pgto.cidade_sacado[0..14]}/#{pgto.uf_sacado}".format_size(40)
        end

        def monta_detalhe(pagamento, sequencial)
          raise Brcobranca::RemessaInvalida, pagamento if pagamento.invalid?
          detalhe = '1'                                                             # identificacao do registro                   9[01]       001 a 001
          detalhe << tipo_registro.rjust(1, "0")                                    # Sim 9(01) 1
          detalhe << debito_automatico.ljust(19, " ")                               # Não X(19) Branco
          detalhe << coobrigacao.rjust(2, "0")                                      # SIM 9(02) 01 =Com Coobrigação 02 = Sem Coobrigação
          detalhe << caracteristica_especial.rjust(2, "0")                          # Não 9(02) Preencher de acordo com o Anexo 8 do layout SRC3040 do Bacen
          detalhe << modalidade_operacao.rjust(4, "0")                              # Não 9(04) Preencher de acordo com o Anexo 3 do layout SRC3040 do Bacen – preencher o domínio e o subdomínio
          detalhe << natureza_operacao.rjust(2 , "0")                               # Não 9(02) Preencher de acordo com o Anexo 2 do layout SRC3040 do Bacen
          detalhe << origem_recurso.rjust(4, "0")                                   # Não 9(04) Preencher de acordo com o Anexo 4 do layout SRC3040 do Bacen– preencher o domínio e o subdomínio
          detalhe << classe_risco_operacao.ljust(2 , " ")                           # Não X(02) Preencher de acordo com o Anexo 17 do layout SRC3040 do Bacen – preencher da esquerda para direita
          detalhe << "".rjust(1, "0")                                               # Não 9(01) Zeros
          detalhe << n_controle_participante.ljust(25, " ")                         # Sim X(25) Nº de Controle do Participante
          detalhe << numero_banco.rjust(3, "0")                                     # Sim 9(03) Se espécie = cheque, o campo é obrigatório. Se espécie diferente de cheque preencher com 000
          detalhe << "".rjust(5, "0")                                               # Sim 9(05) Zeros
          detalhe << nosso_numero.rjust(11, "0")                                    # Não 9(11) Branco
          detalhe << nosso_numero_dv.ljust(1, " ")                                  # Não X(01) Branco
          detalhe << formata_valor(valor_pago, 10)                                  # Não 9(10) Valor pago na liquidação/baixa do título (obrigatório na Liquidação)
          detalhe << condicao_emissao.ljust(1, "0")                                 # Não 9(01) Branco
          detalhe << identificacao_emite_papeleta_debito_automatico.ljust(1, " ")   # Não X(01) Branco
          detalhe << data_liquidacao.strftime('%d%m%y').rjust(6, "0")               # Sim 9(06) DDMMAA (somente para liquidação do título)
          detalhe << identificacao_operacao.ljust(4, " ")                           # Não X(04) Branco
          detalhe << indicador_rateio_credito.ljust(1 , " ")                        # Não X(01) Branco
          detalhe << enderecamento_debito_automatico.rjust(1, "0")                  # Não 9(01) Branco
          detalhe << "".rjust(2, " ")                                               # Não X(02) Branco
          detalhe << identificacao_ocorrencia.rjust(2, "0")                         # Sim 9(02) Vide seção 4.1 números 23 do documento
          detalhe << n_do_documento.ljust(10, " ")                                  # Sim X(10) Nº do Documento
          detalhe << data_vencimento_titulo.strftime('%d%m%y').rjust(6, "0")        # Sim 9(06) DDMMAA
          detalhe << formata_valor(valor_titulo)                                    # Sim 9(13) Valor do Título (preencher sem ponto e sem vírgula)
          detalhe << banco_cobranca.rjust(3, "0")                                   # Não 9(03) Nº do Banco na Câmara de Compensação ou 000
          detalhe << agencia_depositaria.rjust(5, "0")                              # Não 9(05) Código da Agência Depositária ou 00000
          detalhe << especie_titulo.rjust(2 , "0")                                  # Sim 9(02) Espécie de Título
          detalhe << identificacao.ljust(1, " ")                                    # Não X(01) Branco
          detalhe << data_emissao_titulo.strftime('%d%m%y').rjust(6, "0")           # Sim 9(06) DDMMAA
          detalhe << instrucao_1.rjust(2, "0")                                      # Não 9(02) 1ª instrução
          detalhe << instrucao_2.rjust(1, "0")                                      # Não 9(01) 2ª instrução
          detalhe << codigo_de_inscricao_cedente.ljust(2, " ")                      # SIM X(02) 01 - Pessoa Física;  02 - Pessoa Jurídica;
          detalhe << "".rjust(14, "0")                                              # Não X(14) Zeros
          detalhe << numero_termo_cessao.ljust(19, " ")                             # Sim X(19) Conforme número enviado pela consultoria (campos alfa-numéricos)
          detalhe << formata_valor(valor_aquisicao)                                 # Sim 9(13) Valor da parcela na data que foi cedida
          detalhe << formata_valor(valor_abatimento)                                # Não 9(13) Valor do Abatimento a ser concedido na instrução
          detalhe << codigo_de_inscricao_sacado.rjust(2, "0")                       # Sim 9(02) 01-CPF 02-CNPJ
          detalhe << numero_de_inscricao.rjust(14, "0")                             # Sim 9(14) CNPJ/CPF
          detalhe << nome_sacado.ljust(40, " ")                                     # Sim X(40) Nome do Sacado
          detalhe << endereco_completo.ljust(40, " ")                               # Sim X(40) Endereço Completo
          detalhe << n_nota_fiscal.rjust(9, "0")                                    # Sim X(09) Numero da Nota Fiscal da Duplicata
          detalhe << n_serie_nota_fiscal.ljust(3, " ")                              # Não X(03) Numero da Série da Nota Fiscal da Duplicata
          detalhe << cep.rjust(8, "0")                                              # Sim 9(08) CEP
          detalhe << cedente.ljust(60, " ")                                         # Sim X(60) Cedente
          detalhe << nome_Cedente.ljust(46, " ")                                    # Sim X(46) Nome do Cedente
          detalhe << numero_de_inscricao_cedente.ljust(14, " ")                     # Sim X(14) CNPJ do Cedente
          detalhe << chave_nota.ljust(44, " ")                                      # Sim X(44) Chave da Nota Eletrônica
          detalhe << sequencial.rjust(6, "0")                                       # Sim 9(06) Nº Seqüencial do Registro
          detalhe
        end
      end
    end
  end
end
