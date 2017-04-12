# -*- encoding: utf-8 -*-
#
module Brcobranca
  module Remessa
    module Cnab400
      class Itau < Brcobranca::Remessa::Cnab400::Base

        attr_accessor :aceite
        # 'A' – para sim, ou 'N' – para não

        attr_accessor :especie_titulo
        # 01 DUPLICATA MERCANTIL
        # 02 NOTA PROMISSÓRIA
        # 03 NOTA DE SEGURO
        # 04 MENSALIDADE ESCOLAR
        # 05 RECIBO
        # 06 CONTRATO
        # 07 COSSEGUROS
        # 08 DUPLICATA DE SERVIÇO
        # 09 LETRA DE CÂMBIO
        # 13 NOTA DE DÉBITOS
        # 15 DOCUMENTO DE DÍVIDA
        # 16 ENCARGOS CONDOMINIAIS
        # 17 CONTA DE PRESTAÇÃO DE SERVIÇOS
        # 99 DIVERSOS

        attr_accessor :instrucao_cobranca
        # 03 DEVOLVERAPÓS 30 DIAS DO VENCIMENTO
        # Demais revisar documentação

        attr_accessor :primeira_instrucao
        attr_accessor :segunda_instrucao

        validates_presence_of :agencia, :conta_corrente, message: 'não pode estar em branco.'
        validates_presence_of :documento_cedente, :digito_conta, message: 'não pode estar em branco.'
        validates_length_of :agencia, maximum: 4, message: 'deve ter 4 dígitos.'
        validates_length_of :conta_corrente, maximum: 5, message: 'deve ter 5 dígitos.'
        validates_length_of :documento_cedente, minimum: 11, maximum: 14, message: 'deve ter entre 11 e 14 dígitos.'
        validates_length_of :carteira, maximum: 3, message: 'deve ter no máximo 3 dígitos.'
        validates_length_of :digito_conta, maximum: 1, message: 'deve ter 1 dígito.'

        # Nova instancia do Itau
        def initialize(campos = {})
          campos = { aceite: 'A', especie_titulo: '99', instrucao_cobranca: '05', primeira_instrucao: '00', segunda_instrucao: '00' }.merge!(campos)
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
            contador += 1
            ret << monta_detalhe_multa(pagamento, contador)
            if pagamento.tipo_empresa == "03" || pagamento.tipo_empresa == "04"
              contador += 1
              ret << monta_detalhe_avalista(pagamento, contador)
            end
          end
          ret << monta_trailer(contador + 1)

          remittance = ret.join("\n").to_ascii.upcase
          remittance << "\n"

          remittance.encode(remittance.encoding, universal_newline: true).encode(remittance.encoding, crlf_newline: true)
        end

        def agencia=(valor)
          @agencia = valor.to_s.rjust(4, '0') if valor
        end

        def conta_corrente=(valor)
          @conta_corrente = valor.to_s.rjust(5, '0') if valor
        end

        def carteira=(valor)
          @carteira = valor.to_s.rjust(3, '0') if valor
        end

        def cod_banco
          '341'
        end

        def nome_banco
          'BANCO ITAU SA'.ljust(15, ' ')
        end

        # Informacoes da conta corrente do cedente
        #
        # @return [String]
        #
        def info_conta
          # CAMPO            TAMANHO
          # agencia          4
          # complemento      2
          # conta corrente   5
          # digito da conta  1
          # complemento      8
          "#{agencia}00#{conta_corrente}#{digito_conta}#{''.rjust(8, ' ')}"
        end

        # Complemento do header
        # (no caso do Itau, sao apenas espacos em branco)
        #
        # @return [String]
        #
        def complemento
          ''.rjust(294, ' ')
        end

        # Codigo da carteira de acordo com a documentacao o Itau
        # se a carteira nao forem as testadas (150, 191 e 147)
        # retorna 'I' que é o codigo das carteiras restantes na documentacao
        #
        # @return [String]
        #
        def codigo_carteira
          return 'U' if carteira.to_s == '150'
          return '1' if carteira.to_s == '191'
          return 'E' if carteira.to_s == '147'
          'I'
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
          detalhe << pagamento.tipo_empresa                                 # tipo de identificacao da empresa      9[02]
          detalhe << pagamento.documento_empresa.to_s.rjust(14, '0')        # cpf/cnpj da empresa                   9[14]
          detalhe << agencia                                                # agencia                               9[04]
          detalhe << ''.rjust(2, '0')                                       # complemento de registro (zeros)       9[02]
          detalhe << conta_corrente                                         # conta corrente                        9[05]
          detalhe << digito_conta                                           # dac                                   9[01]
          detalhe << ''.rjust(4, ' ')                                       # complemento do registro (brancos)     X[04]
          detalhe << ''.rjust(4, '0')                                       # codigo cancelamento (zeros)           9[04]
          detalhe << pagamento.uso_da_empresa.to_s.rjust(25, ' ')           # identificacao do tit. na empresa      X[25]
          detalhe << pagamento.nosso_numero.to_s.rjust(8, '0')              # nosso numero                          9[08]
          detalhe << ''.rjust(13, '0')                                      # quantidade de moeda variavel          9[13]
          detalhe << carteira                                               # carteira                              9[03]
          detalhe << ''.rjust(21, ' ')                                      # identificacao da operacao no banco    X[21]
          detalhe << codigo_carteira                                        # codigo da carteira                    X[01]
          detalhe << pagamento.identificacao_ocorrencia                     # identificacao ocorrencia              9[02]
          detalhe << pagamento.numero_documento.to_s.rjust(10, ' ')         # numero do documento                   X[10]
          detalhe << pagamento.data_vencimento.strftime('%d%m%y')           # data do vencimento                    9[06]
          detalhe << pagamento.formata_valor                                # valor do documento                    9[13]
          detalhe << cod_banco                                              # codigo banco                          9[03]
          detalhe << ''.rjust(5, '0')                                       # agencia cobradora - deixar zero       9[05]
          detalhe << especie_titulo                                         # especie  do titulo                    X[02]
          detalhe << aceite                                                 # aceite (A/N)                          X[01]
          detalhe << pagamento.data_emissao.strftime('%d%m%y')              # data de emissao                       9[06]
          detalhe << primeira_instrucao.rjust(2, '0')                        # 1a instrucao - deixar zero           X[02]
          detalhe << segunda_instrucao.rjust(2, '0')                        # 2a instrucao - deixar zero            X[02]
          detalhe << pagamento.formata_valor_mora                           # valor mora ao dia                     9[13]
          detalhe << pagamento.formata_data_desconto                        # data limite para desconto             9[06]
          detalhe << pagamento.formata_valor_desconto                       # valor do desconto                     9[13]
          detalhe << pagamento.formata_valor_iof                            # valor do iof                          9[13]
          detalhe << pagamento.formata_valor_abatimento                     # valor do abatimento                   9[13]
          detalhe << pagamento.identificacao_sacado                         # identificacao do pagador              9[02]
          detalhe << pagamento.documento_sacado.to_s.rjust(14, '0')         # documento do pagador                  9[14]
          detalhe << pagamento.nome_sacado.format_size(30)                  # nome do pagador                       X[30]
          detalhe << ''.rjust(10, ' ')                                      # complemento do registro (brancos)     X[10]
          detalhe << pagamento.endereco_sacado.format_size(40)              # endereco do pagador                   X[40]
          detalhe << pagamento.bairro_sacado.format_size(12)                # bairro do pagador                     X[12]
          detalhe << pagamento.cep_sacado                                   # cep do pagador                        9[08]
          detalhe << pagamento.cidade_sacado.format_size(15)                # cidade do pagador                     X[15]
          detalhe << pagamento.uf_sacado                                    # uf do pagador                         X[02]
          if primeira_instrucao == "94" || segunda_instrucao == "94"
            detalhe << pagamento.mensagem_40.format_size(40)                # mensagem 40                           X[30]
          else
            detalhe << pagamento.nome_avalista.format_size(30)                # nome do sacador/avalista              X[30]
            detalhe << ''.rjust(4, ' ')                                       # complemento do registro               X[04]
            detalhe << pagamento.formata_data_multa.rjust(6, '0')             # data da mora                          9[06] *
          end
          detalhe << instrucao_cobranca.rjust(2, '0')                       # quantidade de dias do prazo           9[02] *
          detalhe << ''.rjust(1, ' ')                                       # complemento do registro (brancos)     X[01]
          detalhe << sequencial.to_s.rjust(6, '0')                          # numero do registro no arquivo         9[06]
          detalhe
        end

        def monta_detalhe_multa(pagamento, sequencial)
          raise Brcobranca::RemessaInvalida, pagamento if pagamento.invalid?
          detalhe = '2'                                                     # TIPO DE REGISTRO001               001 9[01]
          detalhe << pagamento.codigo_multa.to_s                            # COD. MULTA CODIGO DA MULTA 002 - 002 X[001]
          detalhe << pagamento.formata_data_multa('%d%m%Y')                 # DATA DA MULTA              003 - 010 9[008]
          detalhe << pagamento.percentual_multa.rjust(13, '0')              # MULTA VALOR/PERCENTUAL     011 - 023 9[013]
          detalhe << ' '.rjust(371, ' ')                                    # BRANCOS                    024 - 394 X[371]
          detalhe << sequencial.to_s.rjust(6, '0')                          # numero do registro   arquivo395 - 400 9[06]
          detalhe
        end

        def monta_detalhe_avalista(pagamento, sequencial)
          raise Brcobranca::RemessaInvalida, pagamento if pagamento.invalid?
          detalhe = '5'                                                         # TIPO DE REGISTRO001               001 9[001]
          detalhe << ' '.rjust(120, ' ')                                        # BRANCOS                    002 - 121 X[120]
          detalhe << Brcobranca::Util::Empresa.new(pagamento.documento_avalista).tipo  # tipo de identificacao da empresa   122 - 123 9[002]
          detalhe << pagamento.documento_avalista.format_size(14).rjust(14, ' ')#                             124 - 137 9[014]
          detalhe << pagamento.endereco_avalista.format_size(40).rjust(40, ' ') #                             138 - 177  9[040]
          detalhe << pagamento.bairro_avalista.format_size(12).rjust(12, ' ')   #                             178 - 189  9[012]
          detalhe << pagamento.cep_avalista.format_size(8).rjust(8, ' ')        #                             190 - 197  9[008]
          detalhe << pagamento.cidade_avalista.format_size(15).rjust(15, ' ')   #                             198 - 212  9[015]
          detalhe << pagamento.uf_avalista.format_size(2).rjust(2, ' ')         #                             213 - 214  9[002]
          detalhe << ' '.rjust(180, ' ')                                        # BRANCOS                     215 - 394 9[180]
          detalhe << sequencial.to_s.rjust(6, '0')                              # numero do registro   arquivo395 - 400 9[006]
          detalhe
        end
      end
    end
  end
end
