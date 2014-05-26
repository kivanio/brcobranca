require 'parseline'
module Brcobranca
  module Retorno
    # Formato de Retorno CNAB 643
    class RetornoCbr643 < Base
      extend ParseLine::FixedWidth # Extendendo parseline

      fixed_width_layout do |parse|
        parse.field :agencia_com_dv,17..21
        parse.field :beneficiario_com_dv,22..30
        parse.field :convenio,31..37
        parse.field :nosso_numero,63..79
        parse.field :tipo_cobranca,80..80
        parse.field :tipo_cobranca_anterior,81..81
        parse.field :natureza_recebimento,86..87
        parse.field :carteira_variacao,91..93
        parse.field :desconto,95..99
        parse.field :iof,100..104
        parse.field :carteira,106..107
        parse.field :comando,108..109
        parse.field :data_liquidacao,110..115
        parse.field :data_vencimento,146..151
        parse.field :valor_titulo,152..164
        parse.field :banco_recebedor,165..167
        parse.field :agencia_recebedora_com_dv,168..172
        parse.field :especie_documento,173..174
        parse.field :data_credito,175..180
        parse.field :valor_tarifa,181..187
        parse.field :outras_despesas,188..200
        parse.field :juros_desconto,201..213
        parse.field :iof_desconto,214..226
        parse.field :valor_abatimento,227..239
        parse.field :desconto_concedito,240..252
        parse.field :valor_recebido,253..265
        parse.field :juros_mora,266..278
        parse.field :outros_recebimento,279..291
        parse.field :abatimento_nao_aproveitado,292..304
        parse.field :valor_lancamento,305..317
        parse.field :indicativo_lancamento,318..318
        parse.field :indicador_valor,319..319
        parse.field :valor_ajuste,320..331
        parse.field :sequencial,394..399
      end
    end
  end
end