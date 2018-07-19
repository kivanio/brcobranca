# -*- encoding: utf-8 -*-
module Brcobranca
  module Remessa
    module Cnab400
      class Bradesco < Brcobranca::Remessa::Cnab400::Base
        # codigo da empresa (informado pelo Bradesco no cadastramento)
        attr_accessor :codigo_empresa

        validates_presence_of :agencia, :conta_corrente, message: 'não pode estar em branco.'
        validates_presence_of :codigo_empresa, :sequencial_remessa,
          :digito_conta, message: 'não pode estar em branco.'
        validates_length_of :codigo_empresa, maximum: 20, message: 'deve ser menor ou igual a 20 dígitos.'
        validates_length_of :agencia, maximum: 5, message: 'deve ter 5 dígitos.'
        validates_length_of :conta_corrente, maximum: 7, message: 'deve ter 7 dígitos.'
        validates_length_of :sequencial_remessa, maximum: 7, message: 'deve ter 7 dígitos.'
        validates_length_of :carteira, maximum: 2, message: 'deve ter no máximo 2 dígitos.'
        validates_length_of :digito_conta, maximum: 1, message: 'deve ter 1 dígito.'

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
          '237'
        end

        def nome_banco
          'BRADESCO'.ljust(15, ' ')
        end

        def complemento
          "#{''.rjust(8, ' ')}MX#{sequencial_remessa}#{''.rjust(277, ' ')}"
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

          detalhe = '1'                                               # identificacao do registro                   9[01]       001 a 001
          detalhe << ''.rjust(5, '0')                                 # agencia de debito (op)                      9[05]       002 a 006
          detalhe << ''.rjust(1, '0')                                 # digito da agencia de debito (op)            X[01]       007 a 007
          detalhe << ''.rjust(5, '0')                                 # razao da conta corrente de debito (op)      9[05]       008 a 012
          detalhe << ''.rjust(7, '0')                                 # conta corrente (op)                         9[07]       013 a 019
          detalhe << ''.rjust(1, '0')                                 # digito da conta corrente (op)               X[01]       020 a 020
          detalhe << identificacao_empresa                            # identficacao da empresa                     X[17]       021 a 037
          detalhe << pagamento.documento_ou_numero.to_s.ljust(25, ' ')   # num. controle                               X[25]       038 a 062
          detalhe << ''.rjust(3, '0')                                 # codigo do banco (debito automatico apenas)  9[03]       063 a 065
          detalhe << pagamento.codigo_multa                           # campo da multa (0 = sem, 2 = com)           9[01]       066 a 066 *
          detalhe << pagamento.formata_percentual_multa               # percentual multa                            9[04]       067 a 070 *
          detalhe << pagamento.nosso_numero.to_s.rjust(11, '0')       # identificacao do titulo (nosso numero)      9[11]       071 a 081
          detalhe << digito_nosso_numero(pagamento.nosso_numero).to_s # digito de conferencia do nosso numero (dv)  X[01]       082 a 082
          detalhe << ''.rjust(10, '0')                                # desconto por dia                            9[10]       083 a 092
          detalhe << '2'                                              # condicao emissao boleto (2 = cliente)       9[01]       093 a 093
          detalhe << 'N'                                              # emite boleto para debito                    X[01]       094 a 094
          detalhe << ''.rjust(10, ' ')                                # operacao no banco (brancos)                 X[10]       095 a 104
          detalhe << ' '                                              # indicador rateio                            X[01]       105 a 105
          detalhe << '2'                                              # endereco para aviso debito (op 2 = ignora)  9[01]       106 a 106
          detalhe << ''.rjust(2, ' ')                                 # brancos                                     X[02]       107 a 108
          detalhe << pagamento.identificacao_ocorrencia               # identificacao ocorrencia                    9[02]
          detalhe << pagamento.numero.to_s.ljust(10, ' ')             # numero do documento alfanum.                X[10]       111 a 120
          detalhe << pagamento.data_vencimento.strftime('%d%m%y')     # data de vencimento                          9[06]       121 a 126
          detalhe << pagamento.formata_valor                          # valor do titulo                             9[13]       127 a 139
          detalhe << ''.rjust(3, '0')                                 # banco encarregado (zeros)                   9[03]       140 a 142
          detalhe << ''.rjust(5, '0')                                 # agencia depositaria (zeros)                 9[05]       143 a 147
          detalhe << '01'                                             # especie do titulo                           9[02]       148 a 149
          detalhe << 'N'                                              # identificacao (sempre N)                    X[01]       150 a 150
          detalhe << pagamento.data_emissao.strftime('%d%m%y')        # data de emissao                             9[06]       151 a 156
          detalhe << ''.rjust(2, '0')                                 # 1a instrucao                                9[02]       157 a 158
          detalhe << ''.rjust(2, '0')                                 # 2a instrucao                                9[02]       159 a 160
          detalhe << pagamento.formata_valor_mora                     # mora                                        9[13]       161 a 173
          detalhe << pagamento.formata_data_desconto                  # data desconto                               9[06]       174 a 179
          detalhe << pagamento.formata_valor_desconto                 # valor desconto                              9[13]       180 a 192
          detalhe << pagamento.formata_valor_iof                      # valor iof                                   9[13]       193 a 205
          detalhe << pagamento.formata_valor_abatimento               # valor abatimento                            9[13]       206 a 218
          detalhe << pagamento.identificacao_sacado                   # identificacao do pagador                    9[02]       219 a 220
          detalhe << pagamento.documento_sacado.to_s.rjust(14, '0')   # cpf/cnpj do pagador                         9[14]       221 a 234
          detalhe << pagamento.nome_sacado.format_size(40)            # nome do pagador                             9[40]       235 a 274
          detalhe << formata_endereco_sacado(pagamento)               # endereco do pagador                         X[40]       275 a 314
          detalhe << ''.rjust(12, ' ')                                # 1a mensagem                                 X[12]       315 a 326
          detalhe << pagamento.cep_sacado[0..4]                       # cep do pagador                              9[05]       327 a 331
          detalhe << pagamento.cep_sacado[5..7]                       # sufixo do cep do pagador                    9[03]       332 a 334
          detalhe << ''.rjust(60, ' ')                                # sacador/2a mensagem - verificar             X[60]       335 a 394
          detalhe << sequencial.to_s.rjust(6, '0')                    # numero do registro do arquivo               9[06]       395 a 400
          detalhe
        end
      end
    end
  end
end
