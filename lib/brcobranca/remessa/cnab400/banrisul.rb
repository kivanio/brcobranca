# -*- encoding: utf-8 -*-
module Brcobranca
  module Remessa
    module Cnab400
      class Banrisul < Brcobranca::Remessa::Cnab400::Base
        attr_accessor :convenio

        validates_presence_of :agencia, :convenio, :sequencial_remessa, message: 'não pode estar em branco.'
        validates_length_of :agencia, maximum: 4, message: 'deve ter 4 dígitos.'
        validates_length_of :sequencial_remessa, maximum: 7, message: 'deve ter 7 dígitos.'
        validates_length_of :convenio, maximum: 13, message: 'deve ter 13 dígitos.'
        validates_length_of :carteira, maximum: 1, message: 'deve ter 1 dígito.'

        def agencia=(valor)
          @agencia = valor.to_s.rjust(4, '0') if valor
        end

        def convenio=(valor)
          @convenio = valor.to_s.rjust(13, '0') if valor
        end

        def sequencial_remessa=(valor)
          @sequencial_remessa = valor.to_s.rjust(7, '0') if valor
        end

        def info_conta
          codigo_cedente.ljust(20, ' ')
        end

        def cod_banco
          '041'
        end

        def nome_banco
          'BANRISUL'.ljust(15, ' ')
        end

        def complemento
          ''.rjust(294, ' ')
        end

        def codigo_cedente
          convenio
        end

        def digito_nosso_numero(nosso_numero)
          nosso_numero.duplo_digito
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
          # brancos               [16]
          # info. conta           [20]
          # empresa mae           [30]
          # cod. banco            [3]
          # nome banco            [15]
          # data geracao          [6]        formato DDMMAA
          # complemento registro  [294]
          # num. sequencial       [6]        000001
          "01REMESSA                 #{info_conta}#{empresa_mae.format_size(30)}#{cod_banco}#{nome_banco}#{data_geracao}#{complemento}000001"
        end

        def monta_detalhe(pagamento, sequencial)
          raise Brcobranca::RemessaInvalida, pagamento if pagamento.invalid?

          detalhe = '1'                                               # identificação do registro                   9[01]       001 a 001
          detalhe << ''.rjust(16, ' ')                                # brancos                                     9[16]       002 a 017
          detalhe << codigo_cedente.rjust(13, ' ')                    # código do cedente                           X[13]       018 a 030
          detalhe << ''.rjust(7, ' ')                                 # brancos                                     X[07]       031 a 037
          detalhe << pagamento.documento_ou_numero.to_s.ljust(25, ' ')# num. controle                               X[25]       038 a 062
          detalhe << pagamento.nosso_numero.to_s.rjust(8, '0')        # identificação do título (nosso número)      9[08]       063 a 070
          detalhe << digito_nosso_numero(pagamento.nosso_numero)      # dígitos de conferência do nosso número (dv) 9[02]       071 a 072
          detalhe << ''.rjust(32, ' ')                                # mensagem no bloqueto                        X[32]       073 a 104
          detalhe << ''.rjust(3, ' ')                                 # brancos                                     X[03]       105 a 107
          detalhe << carteira                                         # carteira                                    9[01]       108 a 108
          detalhe << pagamento.identificacao_ocorrencia               # identificacao ocorrencia                    9[02]       109 a 110
          detalhe << pagamento.documento_ou_numero.to_s.ljust(10, ' ')# numero do documento alfanum.                X[10]       111 a 120
          detalhe << pagamento.data_vencimento.strftime('%d%m%y')     # data de vencimento                          9[06]       121 a 126
          detalhe << pagamento.formata_valor                          # valor do titulo                             9[13]       127 a 139
          detalhe << cod_banco                                        # banco encarregado                           9[03]       140 a 142
          detalhe << ''.rjust(5, ' ')                                 # agencia depositaria (brancos)               9[05]       143 a 147
          detalhe << '08'                                             # especie do titulo                           9[02]       148 a 149
          detalhe << 'N'                                              # identificacao (sempre N)                    X[01]       150 a 150
          detalhe << pagamento.data_emissao.strftime('%d%m%y')        # data de emissao                             9[06]       151 a 156
          detalhe << codigo_primeira_instrucao(pagamento)             # 1a instrucao                                9[02]       157 a 158
          detalhe << pagamento.cod_segunda_instrucao                  # 2a instrucao                                9[02]       159 a 160
          detalhe << tipo_mora(pagamento)                             # tipo de mora (diária ou mensal)             9[13]       161 a 161
          detalhe << formata_valor_mora(12, pagamento)                # mora                                        9[13]       162 a 173
          detalhe << pagamento.formata_data_desconto                  # data desconto                               9[06]       174 a 179
          detalhe << pagamento.formata_valor_desconto                 # valor desconto                              9[13]       180 a 192
          detalhe << pagamento.formata_valor_iof                      # valor iof                                   9[13]       193 a 205
          detalhe << pagamento.formata_valor_abatimento               # valor abatimento                            9[13]       206 a 218
          detalhe << pagamento.identificacao_sacado                   # identificacao do pagador                    9[02]       219 a 220
          detalhe << pagamento.documento_sacado.to_s.rjust(14, '0')   # cpf/cnpj do pagador                         9[14]       221 a 234
          detalhe << pagamento.nome_sacado.format_size(35)            # nome do pagador                             9[35]       235 a 269
          detalhe << ''.rjust(5, ' ')                                 # brancos                                     9[05]       270 a 274
          detalhe << pagamento.endereco_sacado.format_size(40)        # endereco do pagador                         X[40]       275 a 314
          detalhe << ''.rjust(7, ' ')                                 # brancos                                     X[07]       315 a 321
          detalhe << formata_percentual_multa(pagamento)              # percentual multa                            X[02]       322 a 324
          detalhe << '00'                                             # num.dias para a multa após o vencimento     9[02]       325 a 326
          detalhe << pagamento.cep_sacado                             # cep do pagador                              9[08]       327 a 334
          detalhe << pagamento.cidade_sacado.format_size(15)          # cidade do pagador                           9[15]       335 a 349
          detalhe << pagamento.uf_sacado                              # uf do pagador                               9[02]       350 a 351
          detalhe << '0000'                                           # taxa ao dia para pag. antecipado            9[04]       352 a 355
          detalhe << ' '                                              # branco                                      9[01]       356 a 356
          detalhe << ''.rjust(13, '0')                                # valor para cálc. do desconto                9[13]       357 a 369
          detalhe << pagamento.dias_protesto.to_s.rjust(2, '0')       # dias para protesto                          9[02]       370 a 371
          detalhe << ''.rjust(23, ' ')                                # brancos                                     X[23]       370 a 394
          detalhe << sequencial.to_s.rjust(6, '0')                    # numero do registro do arquivo               9[06]       395 a 400
          detalhe
        end

        def monta_trailer(sequencial)
          trailer = "9"
          trailer << ''.rjust(26, ' ')                                # brancos                                     X[26]       002 a 027
          trailer << valor_titulos_carteira(13)                       # total geral/valores dos títulos             9[13]       028 a 040
          trailer << ''.rjust(354, ' ')                               # brancos                                     X[354]      041 a 394
          trailer << sequencial.to_s.rjust(6, '0')                    # sequencial                                  9[06]       395 a 400
          trailer
        end

        private

        def codigo_primeira_instrucao(pagamento)
          return "18" if pagamento.percentual_multa.to_f > 0.00
          pagamento.cod_primeira_instrucao
        end

        def tipo_mora(pagamento)
          return ' ' if pagamento.tipo_mora == '3'
          pagamento.tipo_mora
        end

        def formata_percentual_multa(pagamento)
          raise ValorInvalido, 'Deve ser um Float' if !(pagamento.percentual_multa.to_s =~ /\./)

          sprintf('%.1f', pagamento.percentual_multa).delete('.').rjust(3, '0')
        end

        def formata_valor_mora(tamanho, pagamento)
          return ''.rjust(tamanho, ' ') if pagamento.tipo_mora == '3'
          pagamento.formata_valor_mora(tamanho)
        end

      end
    end
  end
end
