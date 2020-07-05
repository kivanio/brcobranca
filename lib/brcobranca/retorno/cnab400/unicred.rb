# -*- encoding: utf-8 -*-
require 'parseline'

module Brcobranca
  module Retorno
    module Cnab400
      # Formato de Retorno CNAB 400
      class Unicred < Brcobranca::Retorno::Cnab400::Base
        extend ParseLine::FixedWidth

        def self.load_lines(file, options = {})
          # por padrao ignora a primeira linha que é header
          default_options = { except: [1] }
          options = default_options.merge!(options)

          super file, options
        end

        fixed_width_layout do |parse|
          # Todos os campos descritos no documento em ordem
          # :tipo_de_registro, 0..0 # identificacao do registro transacao - Fixo 1
          parse.field :codigo_registro, 0..0

          # :codigo_de_inscricao, 1..2 # identificacao do tipo de inscricao/empresa
          # :numero_de_inscricao, 3..16 # numero de inscricao da empresa (cpf/cnpj)

          # Identificacao da empresa no banco
          # :agencia_com_dv, 17..21
          # :digito_agencia, 21..21
          # :cedente_com_dv, 22..29
          parse.field :agencia_sem_dv, 17..20
          parse.field :cedente_com_dv, 22..30

          # :codigo_beneficiario, 31..44
          # :nosso_numero, 45..61 # identificacao do titulo no banco
          parse.field :nosso_numero, 45..61

          # :FIXO, 62..72 BRANCOS* Este campo deve ser
          # desconsiderado. Ele esta reservado para melhorias.
          # :zeros, 73..73
          # :FIXO, 74..74  # 1 - SIMPLES
          # :FIXO 75..84  BRANCOS* Este campo deve ser
          # desconsiderado. Ele esta reservado para melhorias.
          # :FIXO 85..87 # 019
          # :zeros 88..105
          # :FIXO 106..107  # 18

          # :codigo_ocorrencia 108..109
          parse.field :codigo_ocorrencia, 108..109

          # :data_credito, 110..115 # data de credito desta liquidacao
          parse.field :data_credito, 110..115

          # :FIXO 116..145  BRANCOS* Este campo deve ser
          # desconsiderado. Ele está reservado para melhorias.

          # :vencimento, 146..151 # data de vencimento do titulo (ddmmaa)
          parse.field :data_vencimento, 146..151

          # :valor_do_titulo, 152..164 # valor nominal do titulo
          # (ultimos 2 digitos, virgula decimal assumida)
          parse.field :valor_titulo, 152..164

          # :codigo_do_banco, 165..167 # numero do banco na camara de compensacao
          parse.field :banco_recebedor, 165..167

          # :agencia_recebedora, 168..171 # agencia cobradora,
          # ag de liquidacao ou baixa
          # DV-PREFIXO AGENCIA RECEBEDORA, 172..172 #
          parse.field :agencia_recebedora_com_dv, 168..172

          # :FIXO 173..174  BRANCOS* Este campo deve ser
          # desconsiderado. Ele esta reservado para melhorias.

          # DATA PROGRAMADA PARA REPASSE
          # :data, 175..180

          # :tarifa_de_cobranca, 181..187 # valor da despesa de cobranca
          # (ultimos 2 digitos, virgula decimal assumida)
          parse.field :valor_tarifa, 181..187

          # :FIXO 188..226  BRANCOS* Este campo deve ser
          # desconsiderado. Ele está reservado para melhorias.

          # :valor_abatimento, 227..239 # valor do abatimento concedido
          # (ultimos 2 digitos, virgula decimal assumida)
          parse.field :valor_abatimento, 227..239

          # :descontos, 240..252 # valor do desconto concedid
          # o (ultimos 2 digitos, virgula decimal assumida)
          parse.field :desconto, 240..252

          # :valor_recebido, 253..265 # valor lancado em conta corrente
          # (ultimos 2 digitos, virgula decimal assumida)
          parse.field :valor_recebido, 253..265

          # :juros_mora, 266..278 # valor de mora e multa pagos pelo sacado
          # (ultimos 2 digitos, virgula decimal assumida)
          parse.field :juros_mora, 266..278

          # :numero_controle_empresa, 279..304, # numero de controle da empresa

          # : Valor Liquido, 305..317 Diferença entre: Valor Pago e Valor da
          #   Tarifa (Valor Pago – Valor da Tarifa)

          # :Complemento do Movimento 318..325
          parse.field :motivo_ocorrencia, 318..325, ->(motivos) do
            motivos.scan(/.{2}/).reject(&:blank?).reject{|motivo| motivo == '00'}
          end

          # :Tipo de Instrucao de Origem 326..327

          # :FIXO 328..393  BRANCOS* Este campo deve ser
          # desconsiderado. Ele está reservado para melhorias.

          # :numero_sequencial, 394..399 # numero sequencial no arquivo
          parse.field :sequencial, 394..399
        end
      end
    end
  end
end
