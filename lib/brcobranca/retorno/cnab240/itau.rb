# frozen_string_literal: true

module Brcobranca
  module Retorno
    module Cnab240
      class Itau < Brcobranca::Retorno::Cnab240::Base
        # Regex para remocao de headers/trailers e registros diferentes de T
        # ou U.
        REGEX_DE_EXCLUSAO_DE_REGISTROS_NAO_T_OU_U =
          /^((?!^.{7}3.{5}[TU].*$).)*$/

        def self.load_lines(file, options = {})
          default_options = {
            except: REGEX_DE_EXCLUSAO_DE_REGISTROS_NAO_T_OU_U
          }
          options = default_options.merge(options)

          lines = Line.load_lines(file, options)
          lines.each_slice(2).inject([]) do |retornos, cnab_lines|
            validate_par_t_u!(cnab_lines)
            retornos << generate_retorno_based_on_cnab_lines(cnab_lines)
          end
        end

        # Garante que cada grupo de linhas T/U produzido por .load_lines
        # esta completo e na ordem esperada antes de virar um retorno.
        #
        # Um arquivo corrompido ou truncado pode gerar um grupo com so a
        # linha T (sem a U correspondente) ou fora de ordem; sem essa
        # checagem, generate_retorno_based_on_cnab_lines trataria
        # silenciosamente qualquer linha que nao seja T como se fosse U,
        # produzindo um retorno com dados de liquidacao incorretos/parciais.
        def self.validate_par_t_u!(cnab_lines)
          return if cnab_lines.size == 2 &&
                    cnab_lines[0].tipo_registro == "T" &&
                    cnab_lines[1].tipo_registro == "U"

          sequencial = cnab_lines.first&.sequencial
          raise ArgumentError,
                "Par de registros T/U invalido ou incompleto no retorno " \
                "do Itau (sequencial: #{sequencial.inspect})"
        end

        def self.generate_retorno_based_on_cnab_lines(cnab_lines)
          retorno = new
          cnab_lines.each do |line|
            if line.tipo_registro == "T"
              Line::REGISTRO_T_FIELDS.each do |attr|
                retorno.send(:"#{attr}=", line.send(attr))
              end
            else
              Line::REGISTRO_U_FIELDS.each do |attr|
                retorno.send(:"#{attr}=", line.send(attr))
              end
            end
          end
          retorno
        end

        # Linha de mapeamento do retorno do arquivo CNAB 240 do Itau.
        #
        # O registro CNAB 240 possui 2 tipos de registros que juntos geram
        # um registro de retorno bancario. O primeiro e do tipo T que
        # retorna os dados gerais sobre o titulo/pagador. O segundo e do
        # tipo U que retorna os valores da liquidacao.
        #
        # Os nomes de campo reutilizam, sempre que fazem sentido, o
        # vocabulario generico ja definido em Brcobranca::Retorno::Base (em
        # vez de nomes especificos do Itau), pois e esse vocabulario que
        # fica exposto para quem consome a classe via
        # Brcobranca::Retorno::Cnab240::Base (ex.: a API HTTP do
        # boleto_cnab_api so serializa os atributos ja conhecidos dessa
        # lista generica).
        #
        # Posicoes conforme manual "Cobranca FEBRABAN 240" do Itau, item
        # 3.2 (Arquivo Retorno), Segmentos T e U.
        class Line < Base
          extend ParseLine

          REGISTRO_T_FIELDS = %w[
            codigo_registro codigo_ocorrencia agencia_com_dv carteira
            nosso_numero cedente_com_dv documento_numero data_vencimento
            valor_titulo agencia_recebedora_com_dv valor_tarifa
            motivo_ocorrencia sequencial
          ].freeze
          REGISTRO_U_FIELDS = %w[
            juros_mora desconto_concedito valor_abatimento iof_desconto
            valor_recebido outros_recebimento data_ocorrencia data_credito
          ].freeze

          attr_accessor :tipo_registro

          fixed_width_layout do |parse|
            # comuns aos registros T e U
            parse.field :codigo_registro, 7..7
            parse.field :sequencial, 8..12
            parse.field :tipo_registro, 13..13
            parse.field :codigo_ocorrencia, 15..16

            # segmento T
            parse.field :agencia_com_dv, 18..21
            parse.field :cedente_com_dv, 30..36
            parse.field :carteira, 37..39
            parse.field :nosso_numero, 40..47
            parse.field :documento_numero, 58..67
            parse.field :data_vencimento, 73..80
            parse.field :valor_titulo, 81..95
            parse.field :agencia_recebedora_com_dv, 99..104
            parse.field :valor_tarifa, 198..212
            parse.field :motivo_ocorrencia, 213..220

            # segmento U
            parse.field :juros_mora, 17..31
            parse.field :desconto_concedito, 32..46
            parse.field :valor_abatimento, 47..61
            parse.field :iof_desconto, 62..76
            parse.field :valor_recebido, 77..91
            parse.field :outros_recebimento, 92..106
            parse.field :data_ocorrencia, 137..144
            parse.field :data_credito, 145..152
          end
        end
      end
    end
  end
end
