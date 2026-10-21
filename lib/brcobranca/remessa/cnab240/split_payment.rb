# frozen_string_literal: true

module Brcobranca
  module Remessa
    module Cnab240
      # Registro opcional Segmento X-03: dados do Split Payment (IBS/CBS)
      # enviados ao banco no arquivo de remessa de cobranca.
      #
      # Layout Padrao Febraban 240 posicoes V11.0 (11/09/2026), pagina 85, que
      # substituiu o Segmento Y-57 do layout V10.13 (13/07/2026): a versao
      # vigente do manual e a unica aplicavel, e nela os registros do Split
      # Payment sao os segmentos X-01 a X-11 (na cobranca, o X-03 na remessa e
      # no retorno, acompanhado do X-04 no retorno).
      #
      # O layout e o padrao Febraban, comum a todos os bancos: cada banco
      # habilita o registro incluindo este modulo na propria classe, o que liga
      # o gancho opcional de Brcobranca::Remessa::Cnab240::Base#monta_lote
      # (deteccao por respond_to?, como em #monta_segmento_r). Bancos que ainda
      # nao adotaram o layout nao incluem o modulo e continuam gerando o
      # arquivo como antes.
      #
      # Na remessa o titulo informa o Documento Fiscal (X101, de preenchimento
      # opcional) e o CBS/IBS Informado (X102/X103, sempre preenchidos em
      # conjunto, mesmo que um deles seja zero). Quem decide se o registro e
      # gerado e Brcobranca::Remessa::Pagamento#split_payment?, que leva em
      # conta apenas os valores informados.
      module SplitPayment
        # Monta o registro opcional Segmento X-03 de um titulo.
        #
        # @param pagamento [Brcobranca::Remessa::Pagamento]
        #   objeto com os dados do titulo e do Split Payment
        #
        # @param nro_lote [Integer]
        #   numero do lote no arquivo
        #
        # @param sequencial [Integer]
        #   numero sequencial do registro no lote
        #
        # @return [String]
        #
        def monta_segmento_split(pagamento, nro_lote, sequencial)
          segmento_x = ''                                       # CAMPO                     TAMANHO
          segmento_x += cod_banco                               # codigo banco                  3
          segmento_x << nro_lote.to_s.rjust(4, '0')             # lote de servico               4
          segmento_x << '3'                                     # tipo de registro              1
          segmento_x << sequencial.to_s.rjust(5, '0')           # num. sequencial               5
          segmento_x << 'X'                                     # cod. segmento (G039)          1
          segmento_x << ' '                                     # uso exclusivo                 1
          segmento_x << '03'                                    # id. registro opcional (G067)  2
          segmento_x << pagamento.formata_documento_fiscal(50)  # documento fiscal X101        50
          segmento_x << pagamento.formata_valor_cbs(15)         # CBS informado X102           15
          segmento_x << pagamento.formata_valor_ibs(15)         # IBS informado X103           15
          # X104 a X113 (CBS/IBS Corrigido, Em Aberto e Segregado, ID Split e
          # Tipo do ID Split) sao preenchidos pelo Banco no retorno: na remessa
          # o titulo informa apenas o Documento Fiscal e o CBS/IBS Informado.
          segmento_x << ''.rjust(143, ' ')                      # uso FEBRABAN/CNAB           143
          segmento_x
        end
      end
    end
  end
end
