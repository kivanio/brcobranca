# frozen_string_literal: true

module Brcobranca
  module Retorno
    module Cnab240
      # Retorno CNAB 240 do BTG Pactual (208).
      #
      # Cada título vem em um segmento T (dados do título) seguido de um U
      # (valores). Quando o Bolepix está habilitado, o BTG envia também um
      # segmento Y-04 com a chave Pix/URL do QR Code e o TXID (seção 5.2 do
      # manual em docs/BtgPactual).
      class BtgPactual < Brcobranca::Retorno::Cnab240::Base
        # Mantém apenas os segmentos T, U e Y; descarta headers e trailers.
        REGEX_DE_EXCLUSAO_DE_REGISTROS_NAO_T_U_OU_Y = /^((?!^.{7}3.{5}[TUY].*$).)*$/

        # Lê o arquivo e devolve um retorno por título (T + U + Y-04 opcional).
        def self.load_lines(file, options = {})
          default_options = { except: REGEX_DE_EXCLUSAO_DE_REGISTROS_NAO_T_U_OU_Y }
          options = default_options.merge!(options)

          Line.load_lines(file, options).each_with_object([]) do |line, retornos|
            retornos << new if line.tipo_registro == 'T' || retornos.empty?
            preenche(retornos.last, line)
          end
        end

        def self.preenche(retorno, line)
          campos = case line.tipo_registro
                   when 'T' then Line::REGISTRO_T_FIELDS
                   when 'U' then Line::REGISTRO_U_FIELDS
                   when 'Y' then line.y04? ? Line::REGISTRO_Y04_FIELDS : []
                   else []
                   end
          campos.each { |attr| retorno.send(:"#{attr}=", line.send(attr)) }
        end
        private_class_method :preenche

        # Linha de mapeamento dos segmentos T, U e Y-04 do FEBRABAN 240 v10.9.
        # As faixas são 0-based (posição do manual - 1).
        class Line < Base
          extend ParseLine

          REGISTRO_T_FIELDS = %w[codigo_registro sequencial codigo_ocorrencia agencia_com_dv cedente_com_dv
                                 nosso_numero carteira documento_numero data_vencimento valor_titulo
                                 banco_recebedor agencia_recebedora_com_dv valor_tarifa motivo_ocorrencia].freeze
          REGISTRO_U_FIELDS = %w[juros_mora desconto_concedito valor_abatimento iof_desconto valor_recebido
                                 valor_lancamento outras_despesas outros_recebimento data_ocorrencia
                                 data_credito].freeze
          REGISTRO_Y04_FIELDS = %w[tipo_chave_dict codigo_chave_dict txid].freeze

          attr_accessor :tipo_registro, :codigo_registro_opcional

          # Segmento Y-04 (Bolepix). O manual FEBRABAN 10.9 define '03' como
          # identificação do registro opcional desse segmento e é o que o BTG
          # envia no arquivo de exemplo; '04' é aceito por ser o nome do segmento.
          def y04?
            %w[03 04].include?(codigo_registro_opcional)
          end

          fixed_width_layout do |parse|
            # Comum a todos os segmentos
            parse.field :codigo_registro, 7..7
            parse.field :sequencial, 8..12
            parse.field :tipo_registro, 13..13
            parse.field :codigo_ocorrencia, 15..16

            # Segmento T
            parse.field :agencia_com_dv, 17..22
            parse.field :cedente_com_dv, 23..35
            parse.field :nosso_numero, 37..56
            parse.field :carteira, 57..57
            parse.field :documento_numero, 58..72
            parse.field :data_vencimento, 73..80
            parse.field :valor_titulo, 81..95
            parse.field :banco_recebedor, 96..98
            parse.field :agencia_recebedora_com_dv, 99..104
            parse.field :valor_tarifa, 198..212
            parse.field :motivo_ocorrencia, 213..222, lambda { |motivos|
              motivos.to_s.scan(/.{2}/).reject(&:blank?).reject { |motivo| motivo == '00' }
            }

            # Segmento U
            parse.field :juros_mora, 17..31
            parse.field :desconto_concedito, 32..46
            parse.field :valor_abatimento, 47..61
            parse.field :iof_desconto, 62..76
            parse.field :valor_recebido, 77..91
            parse.field :valor_lancamento, 92..106
            parse.field :outras_despesas, 107..121
            parse.field :outros_recebimento, 122..136
            parse.field :data_ocorrencia, 137..144
            parse.field :data_credito, 145..152

            # Segmento Y-04 (Bolepix)
            parse.field :codigo_registro_opcional, 17..18
            parse.field :tipo_chave_dict, 80..80
            parse.field :codigo_chave_dict, 81..157
            parse.field :txid, 158..192
          end
        end
      end
    end
  end
end
