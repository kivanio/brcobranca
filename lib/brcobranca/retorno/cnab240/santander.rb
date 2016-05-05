# -*- encoding: utf-8 -*-

module Brcobranca
  module Retorno
    module Cnab240
      # Formato de Retorno CNAB 240
      # Baseado em: http://www.caixa.gov.br/downloads/cobranca-caixa-manuais/LEIAUTE_CNAB_240_SIGCB_COBRANCA_CAIXA.pdf
      class Santander < Brcobranca::Retorno::RetornoCnab240
        class Line < Brcobranca::Retorno::RetornoCnab240::Line
          fixed_width_layout do |parse|

            parse.field :nosso_numero, 39..55

            parse.field :carteira, 53..53
            parse.field :data_vencimento, 69..76
            parse.field :valor_titulo, 77..91
            parse.field :banco_recebedor, 92..94

            parse.field :agencia_com_dv, 17..21
            parse.field :cedente_com_dv, 22..35

            parse.field :agencia_recebedora_com_dv, 95..98

            parse.field :valor_tarifa, 193..207

          end
        end
      end
    end
  end
end
