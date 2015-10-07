# -*- encoding: utf-8 -*-
module Brcobranca
  module Remessa
    module Cnab400
      class Santander < Brcobranca::Remessa::Cnab400::Base
        # documento do cedente
        attr_accessor :documento_cedente

        # Código de Transmissão
        # Consultar seu gerente para pegar esse código. Geralmente está no e-mail enviado pelo banco.
        attr_accessor :codigo_transmissao

        attr_accessor :codigo_carteira

        validates_presence_of :documento_cedente, :codigo_transmissao, message: 'não pode estar em branco.'
        validates_length_of :documento_cedente, minimum: 11, maximum: 14, message: 'deve ter entre 11 e 14 dígitos.'
        validates_length_of :carteira, maximum: 3, message: 'deve ter no máximo 3 dígitos.'
        validates_length_of :codigo_transmissao, maximum: 20, message: 'deve ter no máximo 20 dígitos.'

        def initialize(campos = {})
          campos = { aceite: 'N', carteira: '101', codigo_carteira: '1' }.merge!(campos)
          super(campos)
        end

        def cod_banco
          '033'
        end

        def nome_banco
          'SANTANDER'.format_size(15)
        end

        # Informacoes do Código de Transmissão
        #
        # @return [String]
        #
        def info_conta
          # CAMPO                     TAMANHO
          # codigo_transmissao        20
          codigo_transmissao.rjust(20, ' ')
        end

        # Complemento do header
        #
        # @return [String]
        #
        def complemento
          '58'.rjust(294, ' ')
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
          fail Brcobranca::RemessaInvalida.new(pagamento) if pagamento.invalid?

          detalhe = '1'                                                     # identificacao transacao               9[01]
          detalhe << Brcobranca::Util::Empresa.new(documento_cedente).tipo  # tipo de identificacao da empresa      9[02]
          detalhe << documento_cedente.to_s.rjust(14, '0')                  # cpf/cnpj da empresa                   9[14]
          detalhe << codigo_transmissao                                     # Código de Transmissão                 9[20]
          detalhe << ''.rjust(25, ' ')                                      # identificacao do tit. na empresa      X[25]
          detalhe << pagamento.nosso_numero.to_s.rjust(8, '0')              # nosso numero                          9[8]
          detalhe << pagamento.formata_data_segundo_desconto                # data limite para o segundo desconto   9[06]
          detalhe << ''.rjust(1, ' ')                                       # brancos                               X[1]
          detalhe << pagamento.codigo_multa                                 # Com multa = 4, Sem multa = 0          9[1]
          detalhe << pagamento.percentual_multa.rjust(4, '0')               # Percentual multa por atraso %         9[6]
          detalhe << '00'                                                   # Unidade de valor moeda corrente = 00  9[2]
          detalhe << '0'.rjust(13, '0')                                     # Valor do título em outra unidade      9[15]
          detalhe << ''.rjust(4, ' ')                                       # brancos                               X[4]
          detalhe << pagamento.formata_data_multa                           # Data para cobrança de multa           9[6]

          # codigo da carteira
          # 1 = ELETRÔNICA COM REGISTRO
          # 3 = CAUCIONADA ELETRÔNICA
          # 4 = COBRANÇA SEM REGISTRO
          # 5 = RÁPIDA COM REGISTRO
          # (BLOQUETE EMITIDO PELO CLIENTE) 6 = CAUCIONADA RAPIDA
          # 7 = DESCONTADA ELETRÔNICA
          detalhe << codigo_carteira                                        # codigo da carteira                    9[01]

          # Código da ocorrência:
          # 01 = ENTRADA DE TÍTULO
          # 02 = BAIXA DE TÍTULO
          # 04 = CONCESSÃO DE ABATIMENTO
          # 05 = CANCELAMENTO ABATIMENTO
          # 06 = PRORROGAÇÃO DE VENCIMENTO
          # 07 = ALT. NÚMERO CONT.CEDENTE
          # 08 = ALTERAÇÃO DO SEU NÚMERO
          # 09 = PROTESTAR
          # 18 = SUSTAR PROTESTO
          detalhe << pagamento.identificacao_ocorrencia                     # identificacao ocorrencia              9[02]
          detalhe << pagamento.numero_documento.to_s.rjust(10, '0')         # numero do documento                   X[10]
          detalhe << pagamento.data_vencimento.strftime('%d%m%y')           # data do vencimento                    9[06]
          detalhe << pagamento.formata_valor                                # valor do documento                    9[13]
          detalhe << cod_banco                                              # codigo banco                          9[03]
          detalhe << ''.rjust(5, '0')                                       # agencia cobradora - deixar zero       9[05]

          # Espécie de documento:
          # 01 = DUPLICATA
          # 02 = NOTA PROMISSÓRIA
          # 03 = APÓLICE / NOTA DE SEGURO
          # 05 = RECIBO
          # 06 = DUPLICATA DE SERVIÇO
          # 07 = LETRA DE CAMBIO
          detalhe << pagamento.especie_titulo                               # Espécie de documento                  9[02]
          detalhe << aceite                                                 # aceite (A/N)                          X[01]
          detalhe << pagamento.data_emissao.strftime('%d%m%y')              # data de emissao                       9[06]

          # Instrução cobrança
          # 00 = NÃO HÁ INSTRUÇÕES
          # 02 = BAIXAR APÓS QUINZE DIAS DO VENCIMENTO
          # 03 = BAIXAR APÓS 30 DIAS DO VENCIMENTO
          # 04 = NÃO BAIXAR
          # 06 = PROTESTAR (VIDE POSIÇÃO392/393)
          # 07 = NÃO PROTESTAR
          # 08 = NÃO COBRAR JUROS DE MORA
          detalhe << '00'                                                   # Instrução para o título               9[02]
          detalhe << '00'                                                   # Número de dias válidos para instrução 9[02]
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
          detalhe << pagamento.nome_avalista.format_size(30)                # Sacador/Mensagens                     X[30]
          detalhe << ''.rjust(1, ' ')                                       # Brancos                               X[1]
          detalhe << ''.rjust(1, ' ')                                       # Identificador do Complemento          X[1]
          detalhe << ''.rjust(2, ' ')                                       # Complemento                           9[2]
          detalhe << ''.rjust(6, ' ')                                       # Brancos                               X[06]
          # Se identificacao_ocorrencia = 06
          detalhe << '00'.rjust(2, ' ')                                     # Número de dias para protesto          9[02]
          detalhe << ''.rjust(1, ' ')                                       # Brancos                               X[1]
          detalhe << sequencial.to_s.rjust(6, '0')                          # numero do registro no arquivo         9[06]
          detalhe
        end
      end
    end
  end
end
