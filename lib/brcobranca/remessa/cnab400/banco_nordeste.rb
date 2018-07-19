# -*- encoding: utf-8 -*-
module Brcobranca
  module Remessa
    module Cnab400
      class BancoNordeste < Brcobranca::Remessa::Cnab400::Base
        # 1 - Emitido pelo banco
        # 2 - Emitido pelo cliente
        attr_accessor :emissao_boleto

        validates_presence_of :agencia, :conta_corrente, message: 'não pode estar em branco.'
        validates_presence_of :documento_cedente, :digito_conta, message: 'não pode estar em branco.'
        validates_length_of :agencia, maximum: 4, message: 'deve ter 4 dígitos.'
        validates_length_of :conta_corrente, maximum: 7, message: 'deve ter 7 dígitos.'
        validates_length_of :documento_cedente, minimum: 11, maximum: 14, message: 'deve ter entre 11 e 14 dígitos.'
        validates_length_of :carteira, maximum: 2, message: 'deve ter 2 dígitos.'
        validates_length_of :digito_conta, maximum: 1, message: 'deve ter 1 dígito.'
        validates_inclusion_of :carteira, in: %w(21 41 51), message: 'não é válida.'

        # Nova instancia do Banco do Nordeste
        def initialize(campos = {})
          campos = {
            aceite: 'N',
            emissao_boleto: '2'
          }.merge!(campos)

          super(campos)
        end

        def agencia=(valor)
          @agencia = valor.to_s.rjust(4, '0') if valor
        end

        def conta_corrente=(valor)
          @conta_corrente = valor.to_s.rjust(7, '0') if valor
        end

        def carteira=(valor)
          @carteira = valor.to_s.rjust(2, '0') if valor
        end

        def cod_banco
          '004'
        end

        def nome_banco
          'B.DO NORDESTE'.ljust(15, ' ')
        end

        # Informacoes da conta corrente do cedente
        #
        # @return [String]
        #
        def info_conta
          # CAMPO            TAMANHO
          # agencia          4
          # zeros            2
          # conta corrente   7
          # digito da conta  1
          # complemento      6
          "#{agencia}00#{conta_corrente}#{digito_conta}#{''.rjust(6, ' ')}"
        end

        # Complemento do header
        # (no caso do Banco do Nordeste, sao apenas espacos em branco)
        #
        # @return [String]
        #
        def complemento
          ''.rjust(294, ' ')
        end

        # Codigo da carteira de acordo com a documentacao do Banco do Nordeste
        #
        # @return [String]
        #
        def codigo_carteira
          return "I" if carteira.to_s == "51"

          carteiras = {
            "1" => { "21" => "1", "41" => "2" }, # 1 - Emitido pelo banco
            "2" => { "21" => "4", "41" => "5" }  # 2 - Emitido pelo cliente
          }

          carteiras[emissao_boleto.to_s][carteira.to_s]
        end

        # Dígito verificador do nosso número.
        #
        # @param nosso_numero
        #
        # @return [String] 1 caracteres numéricos.
        def digito_nosso_numero(nosso_numero)
          nosso_numero.to_s.rjust(7, '0').modulo11(
            multiplicador: (2..8).to_a,
            mapeamento: { 1 => 0, 10 => 0, 11 => 0 }
          ) { |total| 11 - (total % 11) }
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
          detalhe << ''.rjust(16, ' ')                                      # filler                                 [16]
          detalhe << agencia                                                # agencia                               9[04]
          detalhe << ''.rjust(2, '0')                                       # complemento de registro (zeros)       9[02]
          detalhe << conta_corrente                                         # conta corrente                        9[07]
          detalhe << digito_conta                                           # dac                                   9[01]
          detalhe << pagamento.formata_percentual_multa.to_s[0..1]          # taxa - multa                           [02]
          detalhe << ''.rjust(4, ' ')                                       # filler                                 [04]
          detalhe << pagamento.documento_ou_numero.to_s.ljust(25)                                      # identificacao do tit. na empresa      X[25]
          detalhe << pagamento.nosso_numero.to_s.rjust(7, '0')              # nosso numero                          9[07]
          detalhe << digito_nosso_numero(pagamento.nosso_numero).to_s       # dv nosso numero                       9[01]
          detalhe << ''.rjust(10, '0')                                      # numero do contrato                     [10]
          detalhe << ''.rjust(6, '0')                                       # data do segundo pagamento              [06]
          detalhe << ''.rjust(13, '0')                                      # valor do segundo pagamento             [13]
          detalhe << ''.rjust(8, ' ')                                       # filler                                 [08]
          detalhe << codigo_carteira                                        # codigo da carteira                    X[01]
          detalhe << pagamento.identificacao_ocorrencia                     # identificacao ocorrencia              9[02]
          detalhe << pagamento.numero.to_s.rjust(10, '0')         # numero do documento                   X[10]
          detalhe << pagamento.data_vencimento.strftime('%d%m%y')           # data do vencimento                    9[06]
          detalhe << pagamento.formata_valor                                # valor do documento                    9[13]
          detalhe << cod_banco                                              # codigo banco                          9[03]
          detalhe << ''.rjust(4, '0')                                       # agencia cobradora - deixar zero       9[05]
          detalhe << ' '                                                    # filler                                 [01]
          detalhe << '01'                                                   # especie  do titulo                    X[02]
          detalhe << aceite                                                 # aceite (A/N)                          X[01]
          detalhe << pagamento.data_emissao.strftime('%d%m%y')              # data de emissao                       9[06]
          detalhe << ''.rjust(4, '0')                                       # instrucao - deixar zero                [04]
          detalhe << pagamento.formata_valor_mora                           # valor mora ao dia                     9[13]
          detalhe << pagamento.formata_data_desconto                        # data limite para desconto             9[06]
          detalhe << pagamento.formata_valor_desconto                       # valor do desconto                     9[13]
          detalhe << pagamento.formata_valor_iof                            # valor do iof                          9[13]
          detalhe << pagamento.formata_valor_abatimento                     # valor do abatimento                   9[13]
          detalhe << pagamento.identificacao_sacado                         # identificacao do pagador              9[02]
          detalhe << pagamento.documento_sacado.to_s.rjust(14, '0')         # documento do pagador                  9[14]
          detalhe << pagamento.nome_sacado.format_size(40)                  # nome do pagador                       X[40]
          detalhe << pagamento.endereco_sacado.format_size(40)              # endereco do pagador                   X[40]
          detalhe << pagamento.bairro_sacado.format_size(12)                # bairro do pagador                     X[12]
          detalhe << pagamento.cep_sacado                                   # cep do pagador                        9[08]
          detalhe << pagamento.cidade_sacado.format_size(15)                # cidade do pagador                     X[15]
          detalhe << pagamento.uf_sacado                                    # uf do pagador                         X[02]
          detalhe << pagamento.nome_avalista.format_size(40)                # nome do sacador/avalista              X[30]
          detalhe << "99"                                                   # prazo para protesto                    [02]
          detalhe << "0"                                                    # código da moeda                       X[01]
          detalhe << sequencial.to_s.rjust(6, '0')                          # numero do registro no arquivo         9[06]
          detalhe
        end
      end
    end
  end
end
