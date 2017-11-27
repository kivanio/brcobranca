# -*- encoding: utf-8 -*-
module Brcobranca
  module Remessa
    module Cnab400
      class Citibank < Brcobranca::Remessa::Cnab400::Base
        # Identificação do portfolio.
        # Necessário consultar o Citibank para informações referentes à conta cobrança e carteira do cliente.
        attr_accessor :portfolio

        validates_presence_of :documento_cedente, :portfolio, message: 'não pode estar em branco.'
        validates_length_of :documento_cedente, minimum: 11, maximum: 14, message: 'deve ter entre 11 e 14 dígitos.'
        validates_length_of :carteira, maximum: 1, message: 'deve ter no máximo 1 dígito.'
        validates_length_of :portfolio, maximum: 20, message: 'deve ter no máximo 20 dígitos.'

        # Nova instancia do Citibank
        def initialize(campos = {})
          campos = { aceite: 'N', carteira: '1' }.merge!(campos)
          super(campos)
        end

        def cod_banco
          '745'
        end

        def nome_banco
          'CITIBANK'.ljust(15, ' ')
        end

        # Informacoes da conta corrente do cedente
        #
        # @return [String]
        #
        def info_conta
          # CAMPO            TAMANHO
          # portfolio        20
          portfolio.rjust(20, ' ')
        end

        # Complemento do header
        # (no caso do Citibank, sao apenas espacos em branco)
        #
        # @return [String]
        #
        def complemento
          # CAMPO                              TAMANHO
          # Densidade de gravação              5
          # Unidade de densidade de gravação   3
          '01600BPI'.rjust(294, ' ')
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
          detalhe << portfolio                                              # portfolio                             X[20]
          detalhe << pagamento.documento_ou_numero.to_s.ljust(25)                                      # identificacao do tit. na empresa      X[25]
          detalhe << pagamento.especie_titulo                               # espécie do título                     9[02] - 00 = DMI – Duplicata Mercantil por Indicação, 02 = DM – Duplicata Mercantil
          detalhe << pagamento.nosso_numero.to_s.rjust(12, '0')             # nosso numero                          9[12]
          detalhe << ''.rjust(6, ' ')                                       # brancos                               X[06]
          detalhe << pagamento.formata_data_segundo_desconto                # data limite para o segundo desconto   9[06]
          detalhe << pagamento.formata_valor_segundo_desconto               # valor do segundo desconto             9[13]
          detalhe << '000'                                                  # carne                                 9[03] - Válido apenas quando o campo 148/149 for igual a 03
          detalhe << '000'                                                  # parcela                               9[03] - Só preencher se o banco for imprimir e enviar e for um carnê
          detalhe << carteira                                               # codigo da carteira                    X[01] - Código 1 = Cobrança Simples, Código 2 = Cobrança Caucionada
          detalhe << pagamento.identificacao_ocorrencia                     # identificacao ocorrencia              9[02]
          detalhe << pagamento.numero.to_s.rjust(10, '0')         # numero do documento                   X[10]
          detalhe << pagamento.data_vencimento.strftime('%d%m%y')           # data do vencimento                    9[06]
          detalhe << pagamento.formata_valor                                # valor do documento                    9[13]
          detalhe << cod_banco                                              # codigo banco                          9[03]
          detalhe << ''.rjust(5, '0')                                       # agencia cobradora - deixar zero       9[05]

          # 01 = Banco imprime (apenas boletos simples não personalizados) 03 = Banco imprime de forma personalizada (boletos simples, personalizados e carnês)
          # 07 = Banco não imprime
          # 08 = Impressão via WEB (boleto por e-mail) sem impressão banco 09 = Impressão via WEB (boleto por e-mail) com impressão banco Observações:
          #         - Quando código 03, o cliente deverá entrar em contato com o banco, antes de enviar o arquivo, para definir a personalização do boleto.
          #         - Quando código 07, o campo 065/076, deverá ter o NOSSO NÚMERO atribuído pelo cliente.
          # Se o portfolio do cliente for cobrança flexível:
          # 04 = Título flex com boleto impresso via web (boleto por e-mail), aceita pagamento parcial
          # 06 = Título flex com boleto impresso via web (boleto por e-mail), não aceita pagamento parcial
          # (No caso de Cobrança Flexível, o campo 065/076 – NOSSO NÚMERO, no arquivo remessa, deve ser preenchido pelo cliente,
          # ou será preenchido no banco após a entrada do arquivo no sistema de cobrança, visto que os códigos utilizados serão 04 ou 06 no campo Tipo de Emissão.)
          # (Para a modalidade de Cobrança Flexível, a opção de envio por e- mail deverá ser um parâmetro cadastral.)
          detalhe << '07'                                                   # Tipo de Emissão                       X[02]
          detalhe << aceite                                                 # aceite (A/N)                          X[01]
          detalhe << pagamento.data_emissao.strftime('%d%m%y')              # data de emissao                       9[06]

          # 00 = SEM INSTRUÇÂO: após o vencimento, o título sofrerá a instrução presente no cadastro do cliente. Não havendo instruções no cadastro do cliente, o título será baixado automaticamente após 60 dias e o pagamento, após vencimento, poderá ser restrito ao Citibank
          # 06 = PROTESTAR: quando esta instrução for dada também deverá ser preenchida a posição 159/160
          # 07 = NEGATIVAR: instrução utilizada para envio de título para negativação na Serasa. Quando esta for informada, também deverá ser preenchida as posições 159/160.
          # IMPORTANTE: essa instrução somente poderá ser utilizada após assinatura de contrato específico para o produto.
          # 09 = DEVOLVER: esta é a instrução de BAIXA quando esta instrução for dada também deverá ser preenchida a posição 159/160
          # 10 = SUSTAR PROTESTO: instrução utilizada para títulos que NÃO estejam em cartório
          detalhe << '00'                                                   # Instrução para o título               9[02]

          # Quando posição 157/158 (Instrução para título) conter instrução 06 ou 09,
          # este campo deverá conter a quantidade de dias válidos para execução da instrução.
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

          # Este campo tem 3 finalidades:
          #   a) mensagem da empresa impressa no boleto pelo banco
          #    (para isto na primeira posição deve haver um
          #     asterisco);
          #   b) sem o asterisco, este campo será o nome do Sacador/Avalista, quando preenchido;
          #   c) Se posição 148/149 (Tipo de Emissão) estiver com código 08 ou 09, este campo será o e-mail do sacado.
          detalhe << pagamento.nome_avalista.format_size(40)                # Sacador/Mensagens                     X[40]
          detalhe << ''.rjust(2, ' ')                                       # Brancos                               X[06]
          detalhe << '9'                                                    # moeda                                 9[01] - Código 9 = REAIS Código 5 = Dólar
          detalhe << sequencial.to_s.rjust(6, '0')                          # numero do registro no arquivo         9[06]
          detalhe
        end
      end
    end
  end
end
