# frozen_string_literal: true

require 'parseline'

module Brcobranca
  module Retorno
    module Cnab400
      # Formato de Retorno CNAB 400 Sicredi
      class Sicredi < Brcobranca::Retorno::Cnab400::Base
        extend ParseLine::FixedWidth

        # Carregar as linhas do arquivo, ignorando o header
        def self.load_lines(file, options = {})
          default_options = { except: [1] } # Ignorar primeira linha (header)
          options = default_options.merge!(options)

          super(file, options)
        end

        fixed_width_layout do |parse|
          # Definir layout conforme especificado no manual
          # Código de Registro: 1 - Transação
          parse.field :codigo_registro, 0..0

          # Agência sem dígito verificador (4 posições)
          parse.field :agencia_sem_dv, 17..20

          # Código do Cedente com dígito verificador (9 posições)
          parse.field :cedente_com_dv, 22..30

          # Nosso número (17 posições)
          parse.field :nosso_numero, 45..61

          # Código da ocorrência (2 posições)
          parse.field :codigo_ocorrencia, 108..109

          # Data do crédito (6 posições, formato DDMMAA)
          parse.field :data_credito, 110..115

          # Data de vencimento (6 posições, formato DDMMAA)
          parse.field :data_vencimento, 146..151

          # Valor nominal do título (13 posições, 2 últimas dígitos decimais)
          parse.field :valor_titulo, 152..164

          # Banco Recebedor (3 posições)
          parse.field :banco_recebedor, 165..167

          # Agência Recebedora com dígito verificador (5 posições)
          parse.field :agencia_recebedora_com_dv, 168..172

          # Valor da tarifa de cobrança (7 posições, 2 últimas dígitos decimais)
          parse.field :valor_tarifa, 181..187

          # Valor do abatimento concedido (13 posições, 2 últimas dígitos decimais)
          parse.field :valor_abatimento, 227..239

          # Valor do desconto concedido (13 posições, 2 últimas dígitos decimais)
          parse.field :desconto, 240..252

          # Valor recebido (13 posições, 2 últimas dígitos decimais)
          parse.field :valor_recebido, 253..265

          # Juros e mora pagos (13 posições, 2 últimas dígitos decimais)
          parse.field :juros_mora, 266..278

          # Motivo da ocorrência (8 posições, 4 motivos de 2 posições)
          parse.field :motivo_ocorrencia, 318..325, lambda { |motivos|
            motivos.scan(/.{2}/).reject(&:blank?).reject { |motivo| motivo == '00' }
          }

          # Número sequencial no arquivo (6 posições)
          parse.field :sequencial, 394..399
        end
      end
    end
  end
end
