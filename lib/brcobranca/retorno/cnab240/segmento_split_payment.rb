# frozen_string_literal: true

module Brcobranca
  module Retorno
    module Cnab240
      # Registros opcionais com os dados do Split Payment (IBS/CBS) devolvidos
      # pelo banco no arquivo de retorno de cobranca: Segmento X-03 (dados
      # fiscais e valores de CBS/IBS) e Segmento X-04 (valores da liquidacao do
      # boleto).
      #
      # Layout Padrao Febraban 240 posicoes V11.0 (11/09/2026), paginas 85-86,
      # que substituiu os registros do layout V10.13 (13/07/2026): na versao
      # vigente do manual o Split Payment usa os segmentos X-01 a X-11 (na
      # cobranca, o X-03 na remessa e no retorno, e o X-04 no retorno).
      #
      # Os registros acompanham os segmentos obrigatorios do titulo (T/U) e NAO
      # repetem a identificacao do titulo (nosso numero): por isso quem associa
      # o registro ao titulo e o parser, e nao o layout (veja RegistrosTU).
      #
      # Estenda este modulo na classe Line do retorno (junto do ParseLine) e
      # chame #campos_segmento_split dentro do bloco fixed_width_layout para que
      # os campos passem a ser lidos.
      module SegmentoSplitPayment
        # Identificacao do registro opcional (campo G067), nas posicoes 16-17 do
        # Segmento X. Ela nao e unica no arquivo: o '03' tambem e usado por
        # outros segmentos (ex.: o Y-03, Informacao de Dados do Pagador), por
        # isso a deteccao sempre olha o segmento (posicao 14) junto da
        # identificacao, e nunca a identificacao sozinha.
        IDENTIFICACAO_X03 = '03'
        IDENTIFICACAO_X04 = '04'

        # Campos do Segmento X-03, na ordem em que aparecem no layout.
        CAMPOS_X03 = %i[
          identificacao_registro_opcional
          documento_fiscal
          valor_cbs_informado valor_ibs_informado
          valor_cbs_corrigido valor_ibs_corrigido
          valor_cbs_em_aberto valor_ibs_em_aberto
          valor_cbs_segregado valor_ibs_segregado
          id_split tipo_id_split
        ].freeze

        # Campos do Segmento X-04, na ordem em que aparecem no layout.
        CAMPOS_X04 = %i[
          valor_pago_ausente_split
          valor_repassado_novo_titular
          valor_residual
        ].freeze

        # Registra no layout da linha os campos dos registros opcionais do Split
        # Payment.
        #
        # @param parse [Brcobranca::ParseLine]
        #
        def campos_segmento_split(parse)
          # Lote de Servico (campo G002, posicoes 4-7): identifica o lote de
          # cada linha. O Brcobranca::Retorno::Cnab240::RegistrosTU usa esse
          # campo para nao associar os registros opcionais X-03/X-04 ao titulo
          # de outro lote.
          attr_accessor :lote_servico

          parse.field :lote_servico, 3..6

          # Segmento X-03: dados fiscais e valores de CBS/IBS do titulo
          parse.field :identificacao_registro_opcional, 15..16   # G067 (16-17)
          parse.field :documento_fiscal, 17..66                  # X101 (18-67)
          parse.field :valor_cbs_informado, 67..81               # X102 (68-82)
          parse.field :valor_ibs_informado, 82..96               # X103 (83-97)
          parse.field :valor_cbs_corrigido, 97..111              # X104 (98-112)
          parse.field :valor_ibs_corrigido, 112..126             # X105 (113-127)
          parse.field :valor_cbs_em_aberto, 127..141             # X106 (128-142)
          parse.field :valor_ibs_em_aberto, 142..156             # X107 (143-157)
          parse.field :valor_cbs_segregado, 157..171             # X108 (158-172)
          parse.field :valor_ibs_segregado, 172..186             # X109 (173-187)
          parse.field :id_split, 187..221                        # X112 (188-222)
          parse.field :tipo_id_split, 222..224                   # X113 (223-225)

          # Segmento X-04: valores da liquidacao do boleto
          parse.field :valor_pago_ausente_split, 17..31          # X115 (18-32)
          parse.field :valor_repassado_novo_titular, 32..46      # X117 (33-47)
          parse.field :valor_residual, 47..61                    # X118 (48-62)
        end

        # Copia os dados do Split Payment de uma linha para o retorno, quando a
        # linha e um dos registros opcionais do Split Payment.
        #
        # @param retorno [Brcobranca::Retorno::Base]
        # @param linha [Brcobranca::Retorno::Base]
        #
        # @return [Boolean] true quando a linha era um registro do Split Payment
        #
        def aplica_campos_split_payment(retorno, linha)
          if segmento_split_x03?(linha)
            campos = CAMPOS_X03
          elsif segmento_split_x04?(linha)
            campos = CAMPOS_X04
          else
            return false
          end

          campos.each { |campo| retorno.send("#{campo}=", linha.send(campo)) }
          true
        end

        # O Segmento X-03 (dados fiscais e CBS/IBS do Split Payment)
        #
        # @param linha [Brcobranca::Retorno::Base]
        #
        # @return [Boolean]
        #
        def segmento_split_x03?(linha)
          linha.tipo_registro == 'X' && linha.identificacao_registro_opcional == IDENTIFICACAO_X03
        end

        # O Segmento X-04 (valores da liquidacao do Split Payment)
        #
        # @param linha [Brcobranca::Retorno::Base]
        #
        # @return [Boolean]
        #
        def segmento_split_x04?(linha)
          linha.tipo_registro == 'X' && linha.identificacao_registro_opcional == IDENTIFICACAO_X04
        end
      end
    end
  end
end
