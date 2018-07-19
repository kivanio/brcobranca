# -*- encoding: utf-8 -*-
#

module Brcobranca
  module Retorno
    module Cnab240
      # Formato de Retorno CNAB 240
      # Baseado em: http://www.caixa.gov.br/downloads/cobranca-caixa-manuais/LEIAUTE_CNAB_240_SIGCB_COBRANCA_CAIXA.pdf
      class Caixa < Brcobranca::Retorno::RetornoCnab240
        class Line < Brcobranca::Retorno::RetornoCnab240::Line
          # Fixed width layout for Caixa
          fixed_width_layout do |parse|
            # REGISTRO_T_FIELDS
            # Not applicable
            # :cedente_com_dv

            # Same inherited from parent
            # parse.field :data_vencimento, 73..80
            # parse.field :valor_titulo, 81..95
            # parse.field :banco_recebedor, 96..98
            # parse.field :sequencial, 8..12
            # parse.field :valor_tarifa, 198..212
            # parse.field :agencia_com_dv, 17..22

            parse.field :codigo_ocorrencia, 15..16
            parse.field :nosso_numero, 39..55
            parse.field :agencia_recebedora_com_dv, 99..103
            parse.field :motivo_ocorrencia, 213..222, ->(motivos) do
              motivos.scan(/.{2}/).reject(&:blank?).reject{|motivo| motivo == '00'}
            end

            # REGISTRO_U_FIELDS

            # Same inherited from parent
            # parse.field :desconto_concedito, 32..46
            # parse.field :valor_abatimento, 47..61
            # parse.field :iof_desconto, 62..76
            # parse.field :juros_mora, 17..31
            # parse.field :valor_recebido, 77..91
            # parse.field :outras_despesas, 107..121
            # parse.field :outros_recebimento, 122..136
            # parse.field :data_credito, 145..152
          end
        end
      end
    end
  end
end
