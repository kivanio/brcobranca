# -*- encoding: utf-8 -*-
module Brcobranca
  module Remessa
    module Cnab400
      class Unicred < Brcobranca::Remessa::Cnab400::Base
        # codigo da beneficiario (informado pelo Unicred no cadastramento)
        attr_accessor :codigo_beneficiario

        validates_presence_of :agencia, :conta_corrente, :documento_cedente,
                              :digito_conta, :codigo_beneficiario,
                              message: 'não pode estar em branco.'

        validates_length_of :agencia, maximum: 4, message: 'deve ter 4 dígitos.'
        validates_length_of :conta_corrente, maximum: 5, message: 'deve ter 5 dígitos.'
        validates_length_of :documento_cedente, minimum: 11, maximum: 14, message: 'deve ter entre 11 e 14 dígitos.'
        validates_length_of :carteira, maximum: 2, message: 'deve ter 2 dígitos.'
        validates_length_of :digito_conta, maximum: 1, message: 'deve ter 1 dígito.'

        validates_inclusion_of :carteira, in: %w(21), message: 'não existente para este banco.'

        # Nova instancia do Unicred
        def initialize(campos = {})
          campos = {
            aceite: "N"
          }.merge!(campos)

          super(campos)
        end

        def agencia=(valor)
          @agencia = valor.to_s.rjust(4, "0") if valor
        end

        def conta_corrente=(valor)
          @conta_corrente = valor.to_s.rjust(5, "0") if valor
        end

        def carteira=(valor)
          @carteira = valor.to_s.rjust(2, "0") if valor
        end

        def cod_banco
          "136"
        end

        def nome_banco
          "UNICRED".ljust(15, ' ')
        end

        def identificador_complemento
          " "
        end

        # Numero sequencial utilizado para identificar o boleto.
        # @return [String] 10 caracteres numericos.
        def nosso_numero(nosso_numero)
          nosso_numero.to_s.rjust(10, '0')
        end

        # Digito verificador do nosso numero
        # @return [Integer] 1 caracteres numericos.
        def nosso_numero_dv(nosso_numero)
          "#{nosso_numero}".modulo11(mapeamento: mapeamento_para_modulo_11)
        end

        def nosso_numero_boleto(nosso_numero)
          "#{nosso_numero(nosso_numero)}#{nosso_numero_dv(nosso_numero)}"
        end

        # Retorna o nosso numero
        #
        # @return [String]
        def formata_nosso_numero(nosso_numero)
          "#{nosso_numero_boleto(nosso_numero)}"
        end

        def codigo_beneficiario=(valor)
          @codigo_beneficiario = valor.to_s.rjust(20, '0') if valor
        end

        def info_conta
          codigo_beneficiario
        end

        # Complemento do header
        #
        # @return [String]
        #
        def complemento
          ''.rjust(277, ' ')
        end

        def sequencial_remessa=(valor)
          @sequencial_remessa = valor.to_s.rjust(7, '0') if valor
        end

        def digito_agencia
          # utilizando a agencia com 4 digitos
          # para calcular o digito
          agencia.modulo11(mapeamento: { 10 => 'X' }).to_s
        end

        def digito_conta
          # utilizando a conta corrente com 5 digitos
          # para calcular o digito
          conta_corrente.modulo11(mapeamento: { 10 => '0' }).to_s
        end

        def mapeamento_para_modulo_11
          {
            10 => 0,
            11 => 0
          }
        end

        # Header do arquivo remessa
        #
        # @return [String]
        #
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
          # branco                [7]
          # Codigo da Variacaoo carteira da UNICRED 003 Preencher com 000. [3]  000
          # Numero Sequencial do arquivo [7]
          # complemento registro  [277]
          # num. sequencial       [6]        000001
          "01REMESSA01COBRANCA       #{info_conta}#{empresa_mae.format_size(30)}#{cod_banco}#{nome_banco}#{data_geracao}       000#{sequencial_remessa}#{complemento}000001"
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

          detalhe = '1'                                             # identificacao transacao             9[01]
          detalhe << agencia.rjust(5, '0')                          # Agencia do BENEFICIARIO na UNICRED  9[05] 002 a 006
          detalhe << digito_agencia                                 # Digito da Agência 9[01] 007 a 007
          detalhe << conta_corrente.rjust(12, "0")                  # Conta Corrente 9[12] 008 a 019
          detalhe << digito_conta                                   # Digito da Conta 9[1] 020 a 020
          detalhe << "0"                                            # Zero 9[1] 021 a 021
          detalhe << carteira.rjust(3, "0")                         # Codigo da Carteira 9[3] 022 a 024
          detalhe << "".rjust(13, "0")                              # Zeros 9[13] 025 a 037
          detalhe << "".rjust(25, " ")                              # No Controle do Participante Uso da empresa 9[25] 038 a 062
          detalhe << cod_banco                                      # Codigo do Banco na Camara de Compensacao 9[3] 063 a 065
          detalhe << "00"                                           # Zeros 9[2] 066 a 067
          detalhe << "".rjust(25, " ")                              # Branco 9[25] 068 a 092
          detalhe << "0"                                            # Filler 9[01] 093 a 093
          detalhe << pagamento.codigo_multa                         # Codigo da multa 9[1] 094 a 094
          detalhe << pagamento.formata_percentual_multa(10)         # Valor/Percentual da Multa 9[1] 095 a 104
          detalhe << pagamento.tipo_mora                            # Tipo de Valor Mora 9[1] 105 a 105
          detalhe << "N"                                            # Identificacao de Titulo Descontavel 9[1] 106 a 106
          detalhe << "  "                                           # Branco 9[1] 107 a 108
          detalhe << pagamento.identificacao_ocorrencia             # Identificacao da Ocorrencia 9[2] 109 a 110
          detalhe << pagamento.numero.to_s.rjust(10, '0')           # numero do documento  X[10] 111 a 120
          detalhe << pagamento.data_vencimento.strftime('%d%m%y')   # data do vencimento 9[06] 121 a 126
          detalhe << pagamento.formata_valor                        # valor do documento 9[13] 127 a 139
          detalhe << "".rjust(10, '0')                              # Filler 9[10] 140 a 149
          detalhe << pagamento.cod_desconto                         # Codigo do Desconto 9[1] 150 a 150
          detalhe << pagamento.data_emissao.strftime('%d%m%y')      # data de emissao 9[06] 151 a 156
          detalhe << "0"                                            # Filler 9[01] 157 a 157
          detalhe << pagamento.codigo_protesto                      # Codigo para Protesto 9[1] 158 a 158
          detalhe << pagamento.dias_protesto.rjust(2, '0')          # numero de dias para protesto 9[02] 159 a 160
          detalhe << pagamento.formata_valor_mora(13)               # valor mora ao dia 9[13] 161 a 173
          detalhe << pagamento.formata_data_desconto                # data limite para desconto 9[06] 174 a 179
          detalhe << pagamento.formata_valor_desconto               # valor do desconto 9[13] 180 a 192
          detalhe << formata_nosso_numero(pagamento.nosso_numero)   # nosso numero X[11] 193 a 203
          detalhe << "00"                                           # Zeros 9[2] 204 a 205
          detalhe << pagamento.formata_valor_abatimento(13)         # valor do abatimento  9[13] 206 a 218
          detalhe << pagamento.identificacao_sacado                 # Identificacao do Tipo de Inscricao do Pagador 9[2] 219 a 220
          detalhe << pagamento.documento_sacado.to_s.rjust(14, '0') # documento do pagador 9[14] 221 a 234
          detalhe << pagamento.nome_sacado.format_size(40)          # nome do pagador X[40] 235 a 274
          detalhe << pagamento.endereco_sacado.format_size(40)      # endereco do pagador X[40] 275 a 314
          detalhe << pagamento.bairro_sacado.format_size(12)        # bairro do pagador X[12] 315 a 326
          detalhe << pagamento.cep_sacado                           # cep do pagador 9[08] 327 a 334
          detalhe << pagamento.cidade_sacado.format_size(20)        # cidade do pagador X[15] 335 a 354
          detalhe << pagamento.uf_sacado                            # uf do pagador  X[02] 355 a 356
          detalhe << pagamento.nome_avalista.format_size(38)        # nome do sacador/avalista X[38] 357 a 394
          detalhe << sequencial.to_s.rjust(6, '0')                  # numero do registro no arquivo    9[06] 395 a 400
          detalhe

        end
      end
    end
  end
end
