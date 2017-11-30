# -*- encoding: utf-8 -*-
#
module Brcobranca
  module Remessa
    module Cnab400
      class Sicoob < Brcobranca::Remessa::Cnab400::Base
        # convenio do cedente
        attr_accessor :convenio

        attr_accessor :modalidade_carteira
        # identificacao da emissao do boleto (attr na classe base)
        #   opcoes:
        #     ‘1’ = Banco Emite
        #     ‘2’ = Cliente Emite

        attr_accessor :distribuicao_boleto
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

        # convenio do cedente
        attr_accessor :convenio

        validates_presence_of :agencia, :conta_corrente, :carteira, :convenio, :modalidade_carteira, :tipo_formulario, :digito_conta, :sequencial_remessa, :documento_cedente, message: 'não pode estar em branco.'
        # Remessa 400 - 8 digitos
        # Remessa 240 - 12 digitos
        validates_length_of :conta_corrente, is: 8, message: 'deve ter 8 dígitos.'
        validates_length_of :agencia, is: 4, message: 'deve ter 4 dígitos.'
        validates_length_of :modalidade_carteira, is: 1, message: 'deve ter 1 dígitos.'
        validates_length_of :digito_conta, maximum: 1, message: 'deve ter 1 dígito.'
        validates_length_of :sequencial_remessa, maximum: 7, message: 'deve ter 7 dígitos.'
        validates_length_of :carteira, is: 2, message: 'deve ter 2 dígitos.'
        validates_length_of :documento_cedente, minimum: 11, maximum: 14, message: 'deve ter entre 11 e 14 dígitos.'

        # Com DV
        validates_length_of :convenio, is: 9, message: 'deve ter 9 dígitos.'

        def initialize(campos = {})
          campos = {
            distribuicao_boleto: '2',
            tipo_formulario: '4',
            modalidade_carteira: '2',
            sequencial_remessa: '0000001',
            carteira: '01'
          }.merge!(campos)
          super(campos)
        end

        def cod_banco
          '756'
        end

        def nome_banco
          'BANCOOBCED'.format_size(15)
        end

        # Informacoes do Código de Transmissão
        #
        # @return [String]
        #
        def info_conta
          # CAMPO                     TAMANHO
          # 030   004 9(004) Prefixo da Cooperativa: vide planilha "Capa" deste arquivo
          # 031   001 A(001) Dígito Verificador do Prefixo: vide planilha "Capa" deste arquivo
          # 039   008 9(008) Código do Cliente/Beneficiário: vide planilha "Capa" deste arquivo
          # 040   001 A(001) Dígito Verificador do Código: vide planilha "Capa" deste arquivo
          # 046   006 9(006) Número do convênio líder: Brancos
          "#{agencia}#{digito_agencia}#{convenio}      "
        end

        def digito_agencia
          # utilizando a agencia com 4 digitos
          # para calcular o digito
          agencia.modulo11(mapeamento: { 10 => '0' }).to_s
        end

        # Complemento do header
        #
        # @return [String]
        #
        def complemento
          ''.rjust(287, ' ')
        end

        # Header do arquivo remessa
        #
        # @return [String]
        #
        def monta_header
          # CAMPO TAMANHO    VALOR
          # 001   001 9(001) Identificação do Registro Header: “0” (zero)
          # 002   001 9(001) Tipo de Operação: “1” (um)
          # 009   007 A(007) Identificação por Extenso do Tipo de Operação: "REMESSA"
          # 011   002 9(002) Identificação do Tipo de Serviço: “01” (um)
          # 019   008 A(008) Identificação por Extenso do Tipo de Serviço: “COBRANÇA”
          # 026   007 A(007) Complemento do Registro: Brancos
          # 030   004 9(004) Prefixo da Cooperativa: vide planilha "Capa" deste arquivo
          # 031   001 A(001) Dígito Verificador do Prefixo: vide planilha "Capa" deste arquivo
          # 039   008 9(008) Código do Cliente/Beneficiário: vide planilha "Capa" deste arquivo
          # 040   001 A(001) Dígito Verificador do Código: vide planilha "Capa" deste arquivo
          # 046   006 9(006) Número do convênio líder: Brancos
          # 076   030 A(030) Nome do Beneficiário: vide planilha "Capa" deste arquivo
          # 094   018 A(018) Identificação do Banco: "756BANCOOBCED"
          # 100   006 9(006) Data da Gravação da Remessa: formato ddmmaa
          # 107   007 9(007) Seqüencial da Remessa: número seqüencial acrescido de 1 a cada remessa. Inicia com "0000001"
          # 394   287 A(287) Complemento do Registro: Brancos
          # 400   006 9(006) Seqüencial do Registro:”000001”

          "01REMESSA01COBRANCA       #{info_conta}#{empresa_mae.format_size(30)}#{cod_banco}#{nome_banco}#{data_geracao}#{sequencial_remessa}#{complemento}000001"
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
          detalhe << agencia                                                # Prefixo da Cooperativa                9[4]
          detalhe << digito_agencia                                         # Digito da Cooperativa                 9[1]
          detalhe << conta_corrente                                         # Conta corrente                        9[8]
          detalhe << digito_conta                                           # Digito da conta corrente              9[1]
          detalhe << '000000'                                               # Convênio de Cobrança do Beneficiário: "000000"      9[6]
          detalhe << ''.rjust(25, ' ')                                      # Número de Controle do Participante: Brancos      X[25]
          detalhe << pagamento.nosso_numero.to_s.rjust(12, '0')             # nosso numero com DV                   9[12]
          detalhe << pagamento.parcela.to_s.rjust(2, '0')                   # Número da Parcela: "01" se parcela única   9[02]
          detalhe << '00'                                                   # Grupo de Valor: "00"                  9[02]
          detalhe << '   '                                                  # Complemento do Registro: Brancos      X[03]

          # "Indicativo de Mensagem ou Sacador/Avalista:
          # Brancos: Poderá ser informada nas posições 352 a 391 (SEQ 50) qualquer mensagem para ser impressa no boleto;
          # “A”: Deverá ser informado nas posições 352 a 391 (SEQ 50) o nome e CPF/CNPJ do sacador"
          detalhe << ' '                                                    #      X[01]
          detalhe << '   '                                                  # Prefixo do Título: Brancos            X[03]
          detalhe << '000'                                                  # Variação da Carteira: "000"           9[03]
          detalhe << '0'                                                    # Conta Caução: "0"                     9[01]

          # "Número do Contrato Garantia:
          # Para Carteira 1 preencher ""00000"";
          # Para Carteira 3 preencher com o  número do contrato sem DV."
          detalhe << '00000'                                                # Número do Contrato Garantia           9[05]
          detalhe << '0'                                                    # DV do contrato                        9[01]
          detalhe << '000000'                                               # Numero do borderô: preencher em caso de carteira 3           9[06]
          detalhe << '    '                                                 # Complemento do Registro: Brancos      X[04]

          # "Tipo de Emissão:
          # 1 - Cooperativa
          # 2 - Cliente"
          detalhe << modalidade_carteira # Tipo de Emissão                       9[01]

          # "Carteira/Modalidade:
          # 01 = Simples Com Registro
          # 02 = Simples Sem Registro
          # 03 = Garantida Caucionada "
          detalhe << carteira # codigo da carteira                    9[02]

          # "Comando/Movimento:
          # 01 = Registro de Títulos
          # 02 = Solicitação de Baixa
          # 04 = Concessão de Abatimento
          # 05 = Cancelamento de Abatimento
          # 06 = Alteração de Vencimento
          # 08 = Alteração de Seu Número
          # 09 = Instrução para Protestar
          # 10 = Instrução para Sustar Protesto
          # 11 = Instrução para Dispensar Juros
          # 12 = Alteração de Pagador
          # 31 = Alteração de Outros Dados
          # 34 = Baixa - Pagamento Direto ao Beneficiário

          detalhe << pagamento.identificacao_ocorrencia                     # identificacao ocorrencia              9[02]
          detalhe << pagamento.numero.to_s.rjust(10, '0')         # numero do documento                   X[10]
          detalhe << pagamento.data_vencimento.strftime('%d%m%y')           # data do vencimento                    9[06]
          detalhe << pagamento.formata_valor                                # valor do documento                    9[13]
          detalhe << cod_banco                                              # codigo banco                          9[03]
          detalhe << agencia                                                # Prefixo da Cooperativa                9[4]
          detalhe << digito_agencia                                         # Digito da Cooperativa                 9[1]

          # "Espécie do Título :
          # 01 = Duplicata Mercantil
          # 02 = Nota Promissória
          # 03 = Nota de Seguro
          # 05 = Recibo
          # 06 = Duplicata Rural
          # 08 = Letra de Câmbio
          # 09 = Warrant
          # 10 = Cheque
          # 12 = Duplicata de Serviço
          # 13 = Nota de Débito
          # 14 = Triplicata Mercantil
          # 15 = Triplicata de Serviço
          # 18 = Fatura
          # 20 = Apólice de Seguro
          # 21 = Mensalidade Escolar
          # 22 = Parcela de Consórcio
          # 99 = Outros"
          detalhe << pagamento.especie_titulo                               # Espécie de documento                  9[02]
          detalhe << '0'                                                    # aceite (A=1/N=0)                      X[01]
          detalhe << pagamento.data_emissao.strftime('%d%m%y')              # data de emissao                       9[06]

          # "Primeira instrução codificada:
          # Regras de impressão de mensagens nos boletos:
          # * Primeira instrução (SEQ 34) = 00 e segunda (SEQ 35) = 00, não imprime nada.
          # * Primeira instrução (SEQ 34) = 01 e segunda (SEQ 35) = 01, desconsidera-se as instruções CNAB e imprime as mensagens relatadas no trailler do arquivo.
          # * Primeira e segunda instrução diferente das situações acima, imprimimos o conteúdo CNAB:
          # 00 = AUSENCIA DE INSTRUCOES
          # 01 = COBRAR JUROS
          # 03 = PROTESTAR 3 DIAS UTEIS APOS VENCIMENTO
          # 04 = PROTESTAR 4 DIAS UTEIS APOS VENCIMENTO
          # 05 = PROTESTAR 5 DIAS UTEIS APOS VENCIMENTO
          # 07 = NAO PROTESTAR
          # 10 = PROTESTAR 10 DIAS UTEIS APOS VENCIMENTO
          # 15 = PROTESTAR 15 DIAS UTEIS APOS VENCIMENTO
          # 20 = PROTESTAR 20 DIAS UTEIS APOS VENCIMENTO
          # 22 = CONCEDER DESCONTO SO ATE DATA ESTIPULADA
          # 42 = DEVOLVER APOS 15 DIAS VENCIDO
          # 43 = DEVOLVER APOS 30 DIAS VENCIDO"
          detalhe << '00'                                                   # Instrução para o título               9[02]
          detalhe << '00'                                                   # Número de dias válidos para instrução 9[02]
          detalhe << pagamento.formata_valor_mora(6)                        # valor mora ao dia                     9[06]
          detalhe << pagamento.formata_valor_multa(6)                       # taxa de multa                         9[06]
          detalhe << distribuicao_boleto                                    # indentificacao entrega                9[01]
          detalhe << pagamento.formata_data_desconto                        # data limite para desconto             9[06]
          detalhe << pagamento.formata_valor_desconto                       # valor do desconto                     9[13]

          # "193-193 – Código da moeda
          # 194-205 – Valor IOF / Quantidade Monetária: ""000000000000""
          # Se o código da moeda for REAL, o valor restante representa o IOF.
          # Se o código da moeda for diferente de REAL, o valor restante será a quantidade monetária.
          detalhe << pagamento.formata_valor_iof                            # valor do iof                          9[13]
          detalhe << pagamento.formata_valor_abatimento                     # valor do abatimento                   9[13]
          detalhe << pagamento.identificacao_sacado.rjust(2, '0')           # identificacao do pagador              9[02]
          detalhe << pagamento.documento_sacado.to_s.rjust(14, '0')         # documento do pagador                  9[14]
          detalhe << pagamento.nome_sacado.format_size(40).ljust(40, ' ')   # nome do pagador                       X[40]
          detalhe << pagamento.endereco_sacado.format_size(37).ljust(37, ' ') # endereco do pagador                  X[37]
          detalhe << pagamento.bairro_sacado.format_size(15).ljust(15, ' ') # bairro do pagador                     X[15]
          detalhe << pagamento.cep_sacado                                   # cep do pagador                        9[08]
          detalhe << pagamento.cidade_sacado.format_size(15)                # cidade do pagador                     X[15]
          detalhe << pagamento.uf_sacado                                    # uf do pagador                         X[02]

          # "Observações/Mensagem ou Sacador/Avalista:
          # Quando o SEQ 14 – Indicativo de Mensagem ou Sacador/Avalista - for preenchido com Brancos,
          # as informações constantes desse campo serão impressas no campo “texto de responsabilidade da Empresa”,
          # no Recibo do Sacado e na Ficha de Compensação do boleto de cobrança.
          # Quando o SEQ 14 – Indicativo de Mensagem ou Sacador/Avalista - for preenchido com “A” ,
          # este campo deverá ser preenchido com o nome/razão social do Sacador/Avalista"
          detalhe << ''.rjust(40, ' ') #                                       X[40]

          # "Número de Dias Para Protesto:
          # Quantidade dias para envio protesto. Se = ""0"",
          # utilizar dias protesto padrão do cliente cadastrado na cooperativa. "
          detalhe << '00'                                                   # Número de Dias Para Protesto          x[02]
          detalhe << ' '                                                    # Brancos                               X[1]
          detalhe << sequencial.to_s.rjust(6, '0')                          # numero do registro no arquivo         9[06]
          detalhe
        end

        # Trailer do arquivo remessa
        #
        # @param sequencial
        #   num. sequencial do registro no arquivo
        #
        # @return [String]
        #
        def monta_trailer(sequencial)
          # CAMPO   TAMANHO  VALOR
          # 1 001 001 001 9(01) Identificação Registro Trailler: "9"
          # 2 002 194 193 X(193) Complemento do Registro: Brancos
          # 3 195 234 040 X(40) "Mensagem responsabilidade Beneficiário:
          #   Quando o SEQ 34 = ""01"" e o SEQ 35 = ""01"", preencher com mensagens/intruções de responsabilidade do Beneficiário
          #   Quando o SEQ 34 e SEQ 35 forem preenchidos com valores diferentes destes, preencher com Brancos"
          # 4 235 274 040 X(40) "Mensagem responsabilidade Beneficiário:
          #   Quando o SEQ 34 = ""01"" e o SEQ 35 = ""01"", preencher com mensagens/intruções de responsabilidade do Beneficiário
          #   Quando o SEQ 34 e SEQ 35 forem preenchidos com valores diferentes destes, preencher com Brancos"
          # 5 275 314 040 X(40) "Mensagem responsabilidade Beneficiário:
          #   Quando o SEQ 34 = ""01"" e o SEQ 35 = ""01"", preencher com mensagens/intruções de responsabilidade do Beneficiário
          #   Quando o SEQ 34 e SEQ 35 forem preenchidos com valores diferentes destes, preencher com Brancos"
          # 6 315 354 040 X(40) "Mensagem responsabilidade Beneficiário:
          #   Quando o SEQ 34 = ""01"" e o SEQ 35 = ""01"", preencher com mensagens/intruções de responsabilidade do Beneficiário
          #   Quando o SEQ 34 e SEQ 35 forem preenchidos com valores diferentes destes, preencher com Brancos"
          # 7 355 394 040 X(40) "Mensagem responsabilidade Beneficiário:
          #   Quando o SEQ 34 = ""01"" e o SEQ 35 = ""01"", preencher com mensagens/intruções de responsabilidade do Beneficiário
          #   Quando o SEQ 34 e SEQ 35 forem preenchidos com valores diferentes destes, preencher com Brancos"
          # 8 395 400 006 9(06) Seqüencial do Registro: Incrementado em 1 a cada registro

          "9#{''.rjust(393, '0')}#{sequencial.to_s.rjust(6, '0')}"
        end
      end
    end
  end
end
