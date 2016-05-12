# -*- encoding: utf-8 -*-

module Brcobranca
  module Retorno
    module Cnab240
      # Formato de Retorno CNAB 240
      # Baseado em: http://www.caixa.gov.br/downloads/cobranca-caixa-manuais/LEIAUTE_CNAB_240_SIGCB_COBRANCA_CAIXA.pdf
      class Santander < Brcobranca::Retorno::Cnab240::Base
        # Regex para remoção de headers e trailers além de registros diferentes de T ou U
        REGEX_DE_EXCLUSAO_DE_REGISTROS_NAO_T_OU_U = /^((?!^.{7}3.{5}[T|U].*$).)*$/

        def self.load_lines(file, options = {})
          default_options = { except: REGEX_DE_EXCLUSAO_DE_REGISTROS_NAO_T_OU_U }
          options = default_options.merge!(options)

          Line.load_lines(file, options).each_slice(2).reduce([]) do |retornos, cnab_lines|
            retornos << generate_retorno_based_on_cnab_lines(cnab_lines)
          end
        end

        def self.generate_retorno_based_on_cnab_lines(cnab_lines)
          retorno = new
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

        class Line < Base
          extend ParseLine::FixedWidth # Extendendo parseline

          REGISTRO_T_FIELDS = %w(agencia_com_dv cedente_com_dv nosso_numero nosso_numero_com_dv carteira data_vencimento valor_titulo banco_recebedor agencia_recebedora_com_dv sequencial valor_tarifa)
          REGISTRO_U_FIELDS = %w(desconto_concedito valor_abatimento iof_desconto juros_mora valor_recebido outras_despesas outros_recebimento data_credito data_ocorrencia)

          attr_accessor :tipo_registro


          fixed_width_layout do |parse|
            parse.field :tipo_registro, 13..13
            parse.field :sequencial, 8..12
            parse.field :agencia_com_dv, 17..22
            parse.field :nosso_numero, 40..51
            parse.field :nosso_numero_com_dv, 40..52
            parse.field :carteira, 53..53
            parse.field :data_vencimento, 69..76
            parse.field :valor_titulo, 77..91
            parse.field :banco_recebedor, 92..94
            parse.field :agencia_recebedora_com_dv, 95..98
            parse.field :data_ocorrencia, 137..144
            parse.field :data_credito, 145..152
            parse.field :outras_despesas, 107..121
            parse.field :iof_desconto, 62..76
            parse.field :valor_abatimento, 47..61
            parse.field :desconto_concedito, 32..46
            parse.field :valor_recebido, 77..91
            parse.field :juros_mora, 17..31
            parse.field :outros_recebimento, 122..136
            parse.field :valor_tarifa, 193..207
          end
        end
      end
    end
  end
end
