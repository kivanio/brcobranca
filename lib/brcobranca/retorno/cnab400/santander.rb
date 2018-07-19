# -*- encoding: utf-8 -*-
require 'parseline'

module Brcobranca
  module Retorno
    module Cnab400
      # Formato de Retorno CNAB 400
      # Baseado em: http://download.itau.com.br/bankline/layout_cobranca_400bytes_cnab_itau_mensagem.pdf
      class Santander < Brcobranca::Retorno::Cnab400::Base
        extend ParseLine::FixedWidth # Extendendo parseline

        # Load lines
        def self.load_lines(file, options = {})
          default_options = { except: [1] } # por padrao ignora a primeira linha que é header
          options = default_options.merge!(options)
          super file, options
        end

        fixed_width_layout do |parse|
          # Todos os campos descritos no documento em ordem
          # identificacao do registro transacao
          # começa do 0 então contar com +1 as posições
          parse.field :codigo_registro, 0..0
          parse.field :agencia_com_dv, 17..20
          parse.field :cedente_com_dv, 23..28
          parse.field :nosso_numero, 62..69
          # parse.field :carteira_variacao, 82..84
          parse.field :carteira, 107..107
          parse.field :codigo_ocorrencia, 108..109
          parse.field :data_ocorrencia, 110..115
          # identificados na documentação mas não parseados
          #parse.field :seu_numero, 116..125 seu numero
          #parse.field :nosso_numero, 126..133 nosso numero denovo?
          #parse.field :codigo_rejeicao, 134..135 nosso numero
          parse.field :motivo_ocorrencia, 136..145, ->(motivos) do
            motivos.scan(/.{2}/).reject(&:blank?).reject{|motivo| motivo == '00'}
          end

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
          parse.field :sequencial, 394..399
        end
      end
    end
  end
end
