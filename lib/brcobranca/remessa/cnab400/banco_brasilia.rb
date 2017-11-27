# -*- encoding: utf-8 -*-
module Brcobranca
  module Remessa
    module Cnab400
      class BancoBrasilia < Brcobranca::Remessa::Cnab400::Base
        attr_accessor :convenio

        validates_presence_of :agencia, :conta_corrente, :digito_conta, message: 'não pode estar em branco.'
        validates_length_of :agencia, maximum: 3, message: 'deve ter 3 dígitos.'
        validates_length_of :conta_corrente, maximum: 7, message: 'deve ter 7 dígitos.'
        validates_length_of :carteira, maximum: 1, message: 'deve ter 1 dígito.'
        validates_length_of :digito_conta, maximum: 1, message: 'deve ter 1 dígito.'

        # Nova instancia do Banco do Nordeste
        def initialize(campos = {})
          campos = {
            aceite: 'N',
          }.merge!(campos)

          super(campos)
        end

        def agencia=(valor)
          @agencia = valor.to_s.rjust(3, '0') if valor
        end

        def conta_corrente=(valor)
          @conta_corrente = valor.to_s.rjust(7, '0') if valor
        end

        def carteira=(valor)
          @carteira = valor.to_s.rjust(1, '0') if valor
        end

        def cod_banco
          '070'
        end

        def nome_banco
          ''
        end

        def data_formacao
          Time.now.strftime('%Y%m%d%H%M%S')
        end

        def quantidade_registros
          (pagamentos.size + 1).to_s.rjust(6, '0')
        end

        def monta_header
          "DCB001075#{info_conta}#{data_formacao}#{quantidade_registros}"
        end

        # Informacoes da conta corrente do cedente
        #
        # @return [String]
        #
        def info_conta
          # CAMPO             TAMANHO
          # agencia           3
          # conta corrente    7
          "#{agencia}#{conta_corrente}"
        end

        # Complemento do header
        # (no caso do Banco de Brasilia, não é usado)
        #
        # @return [String]
        #
        def complemento
        end

        # Codigo da carteira de acordo com a documentacao do Banco do Nordeste
        #
        # @return [String]
        #
        def codigo_carteira
          carteira.to_s
        end

        def monta_nosso_numero(pagamento)
          return nosso_numero.rjust(12, "0") if carteira == "3"

          formacao = "#{carteira}#{pagamento.nosso_numero.to_s.rjust(6, "0")}#{cod_banco}"

          formacao << formacao.modulo10.to_s
          formacao << formacao.modulo11(
            multiplicador: (2..7).to_a,
            mapeamento: { 10 => 0, 11 => 0}
          ) { |total| 11 - (total % 11) }.to_s
        end

        def codigo_tipo_juros(pagamento)
          return "50" if pagamento.valor_mora.to_f > 0.0
          "00"
        end

        def codigo_tipo_desconto(pagamento)
          return "52" if pagamento.valor_desconto.to_f > 0.0
          "00"
        end

        # Dígito verificador do nosso número.
        #
        # @param nosso_numero
        #
        # @return [String] 1 caracteres numéricos.
        def digito_nosso_numero(nosso_numero)
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

          detalhe = '01'                                                    # identificacao transacao               9[02]
          detalhe << agencia                                                # agencia                               9[03]
          detalhe << conta_corrente                                         # conta corrente                        9[07]
          detalhe << pagamento.documento_sacado.to_s.rjust(14, '0')         # documento do pagador                  9[14]
          detalhe << pagamento.nome_sacado.format_size(35)                  # nome do pagador                       X[35]
          detalhe << pagamento.endereco_sacado.format_size(35)              # endereco do pagador                   X[35]
          detalhe << pagamento.cidade_sacado.format_size(15)                # cidade do pagador                     X[15]
          detalhe << pagamento.uf_sacado                                    # uf do pagador                         X[02]
          detalhe << pagamento.cep_sacado                                   # cep do pagador                        9[08]
          detalhe << pagamento.identificacao_sacado(false).to_s             # tipo de pessoa                        9[01]
          detalhe << pagamento.documento_ou_numero.to_s.rjust(13, "0")                                      # seu numero                            9[13]
          detalhe << codigo_carteira                                        # categoria de cobranca                 9[01]
          detalhe << pagamento.data_emissao.strftime('%d%m%Y')              # data de emissao                       9[08]
          detalhe << "21"                                                   # tipo do documento                     9[02]
          detalhe << "0"                                                    # código da natureza                    9[01]
          detalhe << "0"                                                    # código da cond. pagamento             9[02]
          detalhe << "02"                                                   # código da moeda                       9[02]
          detalhe << cod_banco                                              # código do banco                       9[03]
          detalhe << agencia.rjust(4, "0")                                  # código da agênica                     9[04]
          detalhe << ''.rjust(30, " ")                                      # praca de cobranca                     X[30]
          detalhe << pagamento.data_vencimento.strftime('%d%m%Y')           # data do vencimento                    9[08]
          detalhe << pagamento.formata_valor(14)                            # valor do documento                    9[14]
          detalhe << monta_nosso_numero(pagamento)                          # nosso numero                          9[12]
          detalhe << codigo_tipo_juros(pagamento)                           # codigo tipo juros                     9[02]
          detalhe << pagamento.formata_valor_mora(14)                       # valor mora ao dia                     9[14]
          detalhe << pagamento.formata_valor_abatimento(14)                 # valor do abatimento                   9[14]
          detalhe << codigo_tipo_desconto(pagamento)                        # codigo tipo desconto                  9[02]
          detalhe << pagamento.formata_data_desconto('%d%m%Y')              # data limite para desconto             9[08]
          detalhe << pagamento.formata_valor_desconto(14)                   # valor do desconto                     9[14]
          detalhe << "00"                                                   # primeira instrucao                    9[02]
          detalhe << "00"                                                   # prazo da instrucao                    9[02]
          detalhe << "00"                                                   # segunda instrucao                     9[02]
          detalhe << "00"                                                   # prazo da instrucao                    9[02]
          detalhe << "00000"                                                # taxa referente a instrucao            9[05]
          detalhe << empresa_mae.format_size(40)                            # emitente do titulo                    X[40]
          detalhe << ''.rjust(40, ' ')                                      # mensagem livre                        X[40]
          detalhe << ''.rjust(32, ' ')                                      # branco                                X[32]
          detalhe
        end
      end
    end
  end
end
