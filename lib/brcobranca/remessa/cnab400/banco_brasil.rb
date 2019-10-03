# -*- encoding: utf-8 -*-
#
module Brcobranca
  module Remessa
    module Cnab400
      class BancoBrasil < Brcobranca::Remessa::Cnab400::Base
        #
        # Documentacao para a geracao do arquivo pode ser encontrada em:
        # http://www.bb.com.br/docs/pub/emp/empl/dwn/Doc2627CBR641Pos7.pdf
        #

        # Convenio
        attr_accessor :convenio
        # Variacao da carteira
        attr_accessor :variacao_carteira
        # OPCIONAL Convenio lider
        attr_accessor :convenio_lider
        # Tipo de cobranca
        #
        # a) Carteiras 11 ou 17:
        #   - 04DSC: Solicitação de registro na Modalidade Descontada
        #   - 08VDR: Solicitação de registro na Modalidade BBVendor
        #   - 02VIN: solicitação de registro na Modalidade Vinculada
        #   - BRANCOS: Registro na Modalidade Simples
        # b) Carteiras 12, 31, 51:
        #   - Brancos
        #
        attr_accessor :tipo_cobranca

        validates_presence_of :agencia, :conta_corrente, :convenio, :variacao_carteira, :documento_cedente, message: 'não pode estar em branco.'

        validates_length_of :agencia, maximum: 4, message: 'deve ser igual a 4 digítos.'
        validates_length_of :conta_corrente, maximum: 8, message: 'deve ser menor ou igual a 8 dígitos.'
        validates_length_of :variacao_carteira, is: 3, message: 'deve ser igual a 3 digítos.'
        validates_length_of :carteira, is: 2, message: 'deve ser igual a 2 digítos.'
        validates_length_of :documento_cedente, minimum: 11, maximum: 14, message: 'deve ter entre 11 e 14 dígitos.'

        # Conta corrente
        #
        # Obs: formata para o padrao com 8 caracteres
        #
        def conta_corrente=(valor)
          @conta_corrente = valor.to_s.rjust(8, '0') if valor
        end

        # Retorna dígito verificador da agência
        #
        # @return [String]
        #
        def agencia_dv
          agencia.modulo11(mapeamento: { 10 => 'X' })
        end

        # Dígito verificador da conta corrente
        #
        # @return [String]
        #
        def conta_corrente_dv
          conta_corrente.modulo11(mapeamento: { 10 => 'X' })
        end

        # Codigo do banco
        #
        def cod_banco
          '001'
        end

        # Nome por extenso do banco
        #
        def nome_banco
          'BANCODOBRASIL'.ljust(15, ' ')
        end

        # Informacoes da conta corrente do cedente
        #
        # @return [String]
        #
        def info_conta
          # CAMPO            TAMANHO
          # agencia          4
          # digito agencia   1
          # conta corrente   8
          # digito da conta  1
          # numero convenio  6
          cc = conta_corrente.to_s.rjust(8, '0')
          "#{agencia}#{agencia_dv}#{cc}#{conta_corrente_dv}#{''.rjust(6, '0')}"
        end

        def complemento
          ret = ''
          ret << sequencial_remessa.to_s.rjust(7, '0')       # sequencial da remessa (nao controlado pelo banco)  9[007]
          ret << ''.ljust(22, ' ')                           # complemento (brancos)                              X[022]
          ret << convenio_lider.to_s.rjust(7, '0')           # numero do convenio lider (opcional)                9[007]
          ret << ''.ljust(258, ' ')                          # complemento (brancos)                              X[258]
        end

        def monta_detalhe(pagamento, sequencial)
          raise Brcobranca::RemessaInvalida, pagamento if pagamento.invalid?

          detalhe = '7'                                                       # identificacao do registro         9[1]  001 a 001
          detalhe << Brcobranca::Util::Empresa.new(documento_cedente).tipo    # tipo de identificacao da empresa  9[02] 002 a 003
          detalhe << documento_cedente.to_s.rjust(14, '0')                    # cpf/cnpj da empresa               9[14] 004 a 017
          detalhe << agencia                                                  # agencia                           9[04] 018 a 021
          detalhe << agencia_dv.to_s                                          # digito agencia                    X[01] 022 a 022
          detalhe << conta_corrente.to_s.rjust(8, '0')                        # conta corrente                    9[08] 023 a 030
          detalhe << conta_corrente_dv.to_s                                   # digito conta corrente             X[01] 031 a 031
          detalhe << convenio.to_s.rjust(7, '0')                              # convenio de cobranca da empresa   9[07] 032 a 038
          detalhe << ''.ljust(25, ' ')                                        # controle do participante          X[25] 039 a 063
          detalhe << convenio.to_s.rjust(7, '0')                              # convenio (montagem nosso numero)  9[07] 064 a 070
          detalhe << pagamento.nosso_numero.to_s.rjust(10, '0')               # nosso numero                      9[10] 071 a 080
          detalhe << '00'                                                     # numero da prestacao (zeros)       9[02] 081 a 082
          detalhe << '00'                                                     # grupo de valor (zeros)            9[02] 083 a 084
          detalhe << '   '                                                    # brancos                           X[03] 085 a 087
          detalhe << ' '                                                      # mensagem ou sacador/avalista      X[01] 088 a 088
          detalhe << '   '                                                    # prefixo do titulo (brancos)       X[03] 089 a 091
          detalhe << variacao_carteira                                        # variacao da carteira              9[03] 092 a 094
          detalhe << '0'                                                      # conta caucao                      9[01] 095 a 095
          detalhe << '000000'                                                 # numero do bordero (zeros)         9[06] 096 a 101
          detalhe << tipo_cobranca.to_s.ljust(5, ' ')                         # tipo de cobranca                  9[05] 102 a 106
          detalhe << carteira                                                 # carteira                          9[02] 107 a 108
          detalhe << pagamento.identificacao_ocorrencia                       # comando / ocorrência              9[02] 109 a 110
          detalhe << pagamento.nosso_numero.to_s.rjust(10, '0')               # numero atribuido pela empresa     X[10] 111 a 120
          detalhe << pagamento.data_vencimento.strftime('%d%m%y')             # data de vencimento                9[06] 121 a 126
          detalhe << pagamento.formata_valor                                  # valor do titulo                   9[13] 127 a 139
          detalhe << cod_banco                                                # numero do banco                   9[03] 140 a 142
          detalhe << '0000'                                                   # prefixo da agencia cobradora      9[04] 143 a 146
          detalhe << ' '                                                      # digito da agencia cobradora       X[01] 147 a 147
          detalhe << pagamento.especie_titulo                                 # especie do titulo                 9[02] 148 a 149
          detalhe << aceite                                                   # aceite do titulo                  X[01] 150 a 150
          detalhe << pagamento.data_emissao.strftime('%d%m%y')                # data de emissao                   9[06] 151 a 156
          detalhe << pagamento.cod_primeira_instrucao.to_s.rjust(2, '0')      # cod. primeira instrucao           9[02] 157 a 158
          detalhe << pagamento.cod_segunda_instrucao.to_s.rjust(2, '0')       # cod. segunda instrucao            9[02] 159 a 160
          detalhe << pagamento.formata_valor_mora                             # valor de mora por dia             9[13] 161 a 173
          detalhe << pagamento.formata_data_desconto                          # data para o desconto              9[06] 174 a 179
          detalhe << pagamento.formata_valor_desconto                         # valor do desconto                 9[13] 180 a 192
          detalhe << pagamento.formata_valor_iof                              # valor do IOF                      9[13] 193 a 205
          detalhe << pagamento.formata_valor_abatimento                       # valor do abatimento               9[13] 206 a 218
          detalhe << pagamento.identificacao_sacado                           # tipo pagador                      9[02] 219 a 220
          detalhe << pagamento.documento_sacado.to_s.rjust(14, '0')           # documento do pagador              9[14] 221 a 234
          detalhe << pagamento.nome_sacado.format_size(37)                    # nome do pagador                   9[37] 235 a 271
          detalhe << '   '                                                    # complemento (brancos)             X[03] 272 a 274
          detalhe << pagamento.endereco_sacado.format_size(40)                # endereco do pagador               X[52] 275 a 314
          detalhe << pagamento.bairro_sacado.format_size(12)                  # bairro do pagador                 X[12] 315 a 326
          detalhe << pagamento.cep_sacado.gsub(/[.-]/i, '')                   # CEP do pagador                    X[08] 327 a 334
          detalhe << pagamento.cidade_sacado.format_size(15)                  # cidade do pagador                 X[15] 335 a 349
          detalhe << pagamento.uf_sacado                                      # UF do pagador                     X[02] 350 a 351
          detalhe << ''.ljust(40, ' ')                                        # informacoes avalista              X[40] 352 a 393 TODO implementar avalista
          detalhe << pagamento.dias_protesto.to_s.ljust(2, ' ')               # numero de dias para protesto      X[02] 392 a 393
          detalhe << ' '                                                      # complemento (brancos)             X[01] 394 a 394
          detalhe << sequencial.to_s.rjust(6, '0')                            # sequencial do registro            9[06] 395 a 400
        end

        def monta_detalhe_multa(pagamento, sequencial)
          raise Brcobranca::RemessaInvalida, pagamento if pagamento.invalid?

          detalhe = '5'
          detalhe << '99'                                                # Tipo de Serviço: “99” (Cobrança de Multa)   9[02]       002 a 003
          detalhe << pagamento.codigo_multa                              # código da multa                             9[01]       004 a 004
          detalhe << pagamento.formata_data_multa                        # Data de Inicio da Cobrança da Multa         9[06]       005 a 010
          detalhe << pagamento.formata_valor_multa(12)                   # percentual multa                            9[12]       011 a 022
          detalhe << ''.rjust(372, ' ')                                  # brancos                                     9[372]      023 a 394
          detalhe << sequencial.to_s.rjust(6, '0')                       # numero do registro do arquivo               9[06]       395 a 400
          detalhe
        end
      end
    end
  end
end
