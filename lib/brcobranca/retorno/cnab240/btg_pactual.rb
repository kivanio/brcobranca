# frozen_string_literal: true

module Brcobranca
  module Retorno
    module Cnab240
      # Retorno CNAB 240 do BTG Pactual (208).
      #
      # Cada titulo vem em um segmento T (dados do titulo) seguido de um U
      # (valores). Quando o Bolepix esta habilitado, o BTG envia tambem um
      # segmento Y-04 com a chave Pix/URL do QR Code e o TXID (secao 5.2 do
      # manual em docs/BtgPactual).
      class BtgPactual < Brcobranca::Retorno::Cnab240::Base
        # Mantem apenas os segmentos T, U e Y; descarta headers e trailers.
        REGEX_DE_EXCLUSAO_DE_REGISTROS_NAO_T_U_OU_Y = /^((?!^.{7}3.{5}[TUY].*$).)*$/
        SEGMENTOS_DE_DETALHE = %w[T U Y].freeze
        ERROS_DE_SEQUENCIA = {
          'T' => 'Segmento T sem o segmento U correspondente',
          'U' => 'Segmento U sem segmento T anterior ou duplicado',
          'Y' => 'Segmento Y sem segmento T anterior'
        }.freeze

        # Le o arquivo e devolve um retorno por titulo (T + U + Y-04 opcional).
        #
        # Cada T precisa ser seguido de exatamente um U antes do proximo T ou
        # do fim do arquivo; o Y e opcional. Arquivo fora dessa ordem levanta
        # ArgumentError, como em Cnab240::Itau, para nao gerar retorno parcial.
        def self.load_lines(file, options = {})
          options = { except: REGEX_DE_EXCLUSAO_DE_REGISTROS_NAO_T_U_OU_Y }.merge!(options)

          retornos = []
          aguardando_u = false
          Line.load_lines(file, options).select { |line| detalhe?(line) }.each do |line|
            aguardando_u = valida_sequencia!(line, aguardando_u, retornos.empty?)
            retornos << new if line.tipo_registro == 'T'
            preenche(retornos.last, line)
          end
          raise ArgumentError, 'Segmento T sem o segmento U correspondente no fim do retorno do BTG Pactual' if aguardando_u

          retornos
        end

        # Mesmo com um filtro `except` proprio do chamador, headers e trailers
        # nunca viram titulo.
        def self.detalhe?(line)
          line.codigo_registro == '3' && SEGMENTOS_DE_DETALHE.include?(line.tipo_registro)
        end
        private_class_method :detalhe?

        # Devolve se, apos esta linha, ainda falta o U do titulo corrente.
        def self.valida_sequencia!(line, aguardando_u, sem_titulo)
          tipo = line.tipo_registro
          invalido = { 'T' => aguardando_u, 'U' => !aguardando_u, 'Y' => sem_titulo }[tipo]
          erro_sequencia!(ERROS_DE_SEQUENCIA[tipo], line) if invalido
          return aguardando_u if tipo == 'Y'

          tipo == 'T'
        end
        private_class_method :valida_sequencia!

        def self.erro_sequencia!(mensagem, line)
          raise ArgumentError, "#{mensagem} no retorno do BTG Pactual (sequencial: #{line.sequencial.inspect})"
        end
        private_class_method :erro_sequencia!

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
        # As faixas sao 0-based (posicao do manual - 1).
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
          # identificacao do registro opcional desse segmento e e o que o BTG
          # envia no arquivo de exemplo; '04' e aceito por ser o nome do segmento.
          def y04?
            %w[03 04].include?(codigo_registro_opcional)
          end

          # Faixas de cada segmento (0-based, inclusivas).
          CAMPOS_COMUNS = {
            codigo_registro: 7..7, sequencial: 8..12, tipo_registro: 13..13, codigo_ocorrencia: 15..16
          }.freeze
          CAMPOS_SEGMENTO_T = {
            agencia_com_dv: 17..22, cedente_com_dv: 23..35, nosso_numero: 37..56, carteira: 57..57,
            documento_numero: 58..72, data_vencimento: 73..80, valor_titulo: 81..95, banco_recebedor: 96..98,
            agencia_recebedora_com_dv: 99..104, valor_tarifa: 198..212
          }.freeze
          CAMPOS_SEGMENTO_U = {
            juros_mora: 17..31, desconto_concedito: 32..46, valor_abatimento: 47..61, iof_desconto: 62..76,
            valor_recebido: 77..91, valor_lancamento: 92..106, outras_despesas: 107..121,
            outros_recebimento: 122..136, data_ocorrencia: 137..144, data_credito: 145..152
          }.freeze
          CAMPOS_SEGMENTO_Y04 = {
            codigo_registro_opcional: 17..18, tipo_chave_dict: 80..80, codigo_chave_dict: 81..157, txid: 158..192
          }.freeze

          fixed_width_layout do |parse|
            [CAMPOS_COMUNS, CAMPOS_SEGMENTO_T, CAMPOS_SEGMENTO_U, CAMPOS_SEGMENTO_Y04].each do |campos|
              campos.each { |nome, faixa| parse.field nome, faixa }
            end

            # Segmento T: ate 5 motivos de 2 posicoes, descartando brancos e '00'.
            parse.field :motivo_ocorrencia, 213..222, lambda { |motivos|
              motivos.to_s.scan(/.{2}/).reject(&:blank?).reject { |motivo| motivo == '00' }
            }
          end
        end
      end
    end
  end
end
