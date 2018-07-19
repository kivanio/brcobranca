# -*- encoding: utf-8 -*-
#
# DEPRECATED
#
# Classe original desenvolvida a partir do layout do Itau.
# Movido para: cnab400/itau.rb
#
require 'parseline'
module Brcobranca
  module Retorno
    # Formato de Retorno CNAB 400

    # Baseado em: http://download.itau.com.br/bankline/layout_cobranca_400bytes_cnab_itau_mensagem.pdf
    class RetornoCnab400 < Base
      extend ParseLine::FixedWidth # Extendendo parseline

      def self.load_lines(file, options = {})
        default_options = { except: [1] } # por padrao ignora a primeira linha que é header
        options = default_options.merge!(options)

        super file, options
      end

      fixed_width_layout do |parse|
        parse.field :codigo_registro, 0..0
        parse.field :agencia_com_dv, 17..20 # FIXME - SEM DIV
        parse.field :cedente_com_dv, 23..28
        parse.field :nosso_numero, 62..69
        parse.field :carteira_variacao, 82..84
        parse.field :carteira, 107..107
        parse.field :codigo_ocorrencia, 108..109
        parse.field :data_ocorrencia, 110..115
        parse.field :data_vencimento, 146..151
        parse.field :valor_titulo, 152..164
        parse.field :banco_recebedor, 165..167
        parse.field :agencia_recebedora_com_dv, 168..172
        parse.field :especie_documento, 173..174
        parse.field :valor_tarifa, 175..187
        parse.field :iof, 214..226
        parse.field :valor_abatimento, 227..239
        parse.field :desconto, 240..252
        parse.field :valor_recebido, 253..265
        parse.field :juros_mora, 266..278
        parse.field :outros_recebimento, 279..291
        parse.field :data_credito, 295..300
        parse.field :motivo_ocorrencia, 377..384, ->(motivos) do
          motivos.scan(/.{2}/).reject(&:blank?).reject{|motivo| motivo == '00'}
        end
        parse.field :sequencial, 394..399

        # Campos da classe base que não encontrei a relação com CNAB400
        # parse.field :tipo_cobranca,80..80
        # parse.field :tipo_cobranca_anterior,81..81
        # parse.field :natureza_recebimento,86..87
        # parse.field :convenio,31..37
        # parse.field :comando,108..109
        # parse.field :juros_desconto,201..213
        # parse.field :iof_desconto,214..226
        # parse.field :desconto_concedito,240..252
        # parse.field :outras_despesas,279..291
        # parse.field :abatimento_nao_aproveitado,292..304
        # parse.field :data_liquidacao,295..300
        # parse.field :valor_lancamento,305..317
        # parse.field :indicativo_lancamento,318..318
        # parse.field :indicador_valor,319..319
        # parse.field :valor_ajuste,320..331
      end
    end
  end
end
