# -*- encoding: utf-8 -*-

module Brcobranca
  module Retorno
    module Cnab400
      class Banrisul < Brcobranca::Retorno::Cnab400::Base
        extend ParseLine::FixedWidth # Extendendo parseline

        def self.load_lines(file, options = {})
          default_options = { except: [1] } # por padrao ignora a primeira linha que é header
          options = default_options.merge!(options)
          super file, options
        end

        fixed_width_layout do |parse|
          parse.field :codigo_registro, 0..0
          parse.field :agencia_sem_dv, 17..20
          parse.field :cedente_com_dv, 21..29
          parse.field :nosso_numero, 62..71
          parse.field :carteira, 107..107
          parse.field :codigo_ocorrencia, 108..109
          parse.field :data_ocorrencia, 110..115
          parse.field :data_vencimento, 146..151
          parse.field :valor_titulo, 152..164
          parse.field :banco_recebedor, 165..167
          parse.field :agencia_recebedora_com_dv, 168..172
          parse.field :especie_documento, 173..174
          parse.field :valor_tarifa, 175..187
          parse.field :iof, 188..200
          parse.field :valor_abatimento, 227..239
          parse.field :desconto, 240..252
          parse.field :valor_recebido, 253..265
          parse.field :juros_mora, 266..278
          parse.field :outros_recebimento, 279..291
          parse.field :data_credito, 295..300
          parse.field :motivo_ocorrencia, 382..391
          parse.field :sequencial, 394..399
        end
      end
    end
  end
end
