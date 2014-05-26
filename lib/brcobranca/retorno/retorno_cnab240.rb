require 'parseline'
module Brcobranca
  module Retorno
    # Formato de Retorno CNAB 240
    class RetornoCnab240 < Base
      # Regex para remoção de headers e trailers além de registros diferentes de T ou U
      REGEX_DE_EXCLUSAO_DE_REGISTROS_NAO_T_OU_U = /^((?!^.{7}3.{5}[T|U].*$).)*$/

      def self.load_lines(file, options={})
        default_options = {:except => REGEX_DE_EXCLUSAO_DE_REGISTROS_NAO_T_OU_U}
        options = default_options.merge!(options)

        Line.load_lines(file, options).each_slice(2).inject([]) do |retornos, cnab_lines|
          retornos << generate_retorno_based_on_cnab_lines(cnab_lines)
        end
      end

      def self.generate_retorno_based_on_cnab_lines(cnab_lines)
        retorno = self.new
        cnab_lines.each do |line|
          if line.tipo_registro == 'T'
            Line::REGISTRO_T_FIELDS.each do |attr|
              retorno.send(attr + '=', line.send(attr))
            end
          else
            Line::REGISTRO_U_FIELDS.each do |attr|
              retorno.send(attr + '=', line.send(attr))
            end
          end
        end
        retorno
      end

      # Linha de mapeamento do retorno do arquivo CNAB 240
      # O registro CNAB 240 possui 2 tipos de registros que juntos geram um registro de retorno bancário
      # O primeiro é do tipo T que retorna dados gerais sobre a transação
      # O segundo é do tipo U que retorna os valores da transação
      class Line < Base
        extend ParseLine::FixedWidth # Extendendo parseline

        REGISTRO_T_FIELDS = %w(agencia_com_dv beneficiario_com_dv nosso_numero carteira data_vencimento valor_titulo banco_recebedor agencia_recebedora_com_dv sequencial valor_tarifa)
        REGISTRO_U_FIELDS = %w(desconto_concedito valor_abatimento iof_desconto juros_mora valor_recebido outras_despesas outros_recebimento data_credito)

        attr_accessor :tipo_registro

        fixed_width_layout do |parse|
          parse.field :tipo_registro, 13..13
          parse.field :sequencial,8..12
          parse.field :agencia_com_dv,17..22
          parse.field :beneficiario_com_dv,23..35
          parse.field :nosso_numero,46..56
          parse.field :carteira,57..57
          parse.field :data_vencimento,73..80
          parse.field :valor_titulo,81..95
          parse.field :banco_recebedor,96..98
          parse.field :agencia_recebedora_com_dv,99..104
          parse.field :data_credito,145..152
          parse.field :outras_despesas,107..121
          parse.field :iof_desconto,62..76
          parse.field :valor_abatimento,47..61
          parse.field :desconto_concedito,32..46
          parse.field :valor_recebido,77..91
          parse.field :juros_mora,17..31
          parse.field :outros_recebimento,122..136
          parse.field :valor_tarifa,198..212

          # Dados que não consegui extrair dos registros T e U
          #parse.field :convenio,31..37
          #parse.field :tipo_cobranca,80..80
          #parse.field :tipo_cobranca_anterior,81..81
          #parse.field :natureza_recebimento,86..87
          #parse.field :carteira_variacao,91..93
          #parse.field :desconto,95..99
          #parse.field :iof,100..104
          #parse.field :comando,108..109
          #parse.field :data_liquidacao,110..115
          #parse.field :especie_documento,173..174
          #parse.field :valor_tarifa,181..187
          #parse.field :juros_desconto,201..213
          #parse.field :abatimento_nao_aproveitado,292..304
          #parse.field :valor_lancamento,305..317
          #parse.field :indicativo_lancamento,318..318
          #parse.field :indicador_valor,319..319
          #parse.field :valor_ajuste,320..331
        end
      end
    end
  end
end

