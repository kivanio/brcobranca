# -*- encoding: utf-8 -*-
#
require 'parseline'

module Brcobranca
  module Retorno
    module Cnab400
      # Formato de Retorno CNAB 400
      # Baseado em: http://www.bb.com.br/docs/pub/emp/empl/dwn/Doc2628CBR643Pos7.pdf
      class BancoBrasil < Brcobranca::Retorno::Cnab400::Base
        extend ParseLine::FixedWidth # Extendendo parseline

        # Load lines
        def self.load_lines(file, options = {})
          default_options = { except: [1] } # por padrao ignora a primeira linha que é header
          options = default_options.merge!(options)
          super file, options
        end

        fixed_width_layout do |parse|
          # Todos os campos descritos no documento em ordem
          # :tipo_de_registro, 0..0 # identificacao do registro transacao
          # :zeros, 1..2 # zeros
          # :zeros, 3..16 #zeros

          # :agencia, 17..21 #agencia mantenedora da conta com digito
          parse.field :agencia_com_dv, 17..21

          # :conta, 22..30 #numero da conta corrente da empresa com digito
          parse.field :cedente_com_dv, 22..30

          # :convenio, 31..37 #convenio da empresa
          # :uso_da_empresa, 38..62 #identificacao do titulo na empresa

          # :nosso_numero,63..79 # identificacao do titulo no banco
          parse.field :nosso_numero, 63..79

          # :tipo_cobranca, 80..80 #tipo de cobranca
          # :tipo_cobranca_anterior, 81..81 #tipo de cobranca

          # :dias, 82..85 #dias para calculo

          # :natureza_recebimento, 86..87 #natureza do recebimento
          parse.field :motivos_de_ocorrencia, 86..87, ->(motivos) { motivos.scan(/../).reject { |n| n.to_i.zero? } }

          # :prefixo_titulo, 88..90 #prefixo do titulo
          parse.field :carteira_variacao, 91..93

          # :conta_caucao, 94..94 #conta caução
          # :taxa_desconto, 95..99 #taxa para desconto
          # :taxa_iof, 100..104 #taxa para iof

          # :brancos, 105..105 #brancos
          parse.field :carteira, 106..107

          # :cod_de_ocorrencia, 108..109 # cod de ocorrencia no banco
          parse.field :codigo_ocorrencia, 108..109

          # :data_de_ocorrencia, 110..115 # data de ocorrencia no banco (ddmmaa)
          parse.field :data_ocorrencia, 110..115

          # :n_do_documento, 116..125 # n umero do documento de cobranca (dupl, np etc)
          # :brancos, 126..145 #complemento de registro

          # :vencimento, 146..151 #data de vencimento do titulo (ddmmaa)
          parse.field :data_vencimento, 146..151

          # :valor_do_titulo, 152..164 #valor nominal do titulo (ultimos 2 digitos, virgula decimal assumida)
          parse.field :valor_titulo, 152..164

          # :codigo_do_banco, 165..167 # numero do banco na camara de compensacao
          parse.field :banco_recebedor, 165..167

          # :agencia_cobradora, 168..171 # agencia cobradora, ag de liquidacao ou baixa
          # :dac_ag_cobradora, 172..172 # dac da agencia cobradora
          parse.field :agencia_recebedora_com_dv, 168..172

          # :especie, 173..174 # especie do titulo
          parse.field :especie_documento, 173..174

          # :data_credito, 295..300 #data de credito desta liquidacao
          parse.field :data_credito, 175..180

          # :tarifa_de_cobranca, 175..187 #valor da despesa de cobranca (ultimos 2 digitos, virgula decimal assumida)
          parse.field :valor_tarifa, 181..187

          # parse.field :outras_despesas, 188..200
          # parse.field :juros_desconto, 201..213
          # parse.field :iof_desconto, 214..226

          # :valor_do_iof, 214..226 #valor do iof a ser recolhido (ultimos 2 digitos, virgula decimal assumida)
          parse.field :iof, 214..226

          # :valor_abatimento, 227..239 #valor do abatimento concedido (ultimos 2 digitos, virgula decimal assumida)
          parse.field :valor_abatimento, 227..239

          # :descontos, 240..252 #valor do desconto concedido (ultimos 2 digitos, virgula decimal assumida)
          parse.field :desconto, 240..252

          # :valor_principal, 253..265 #valor lancado em conta corrente (ultimos 2 digitos, virgula decimal assumida)

          parse.field :valor_recebido, 253..265

          # :juros_mora_multa, 266..278 #valor de mora e multa pagos pelo sacado (ultimos 2 digitos, virgula decimal assumida)
          parse.field :juros_mora, 266..278

          # :outros_creditos, 279..291 #valor de outros creditos (ultimos 2 digitos, virgula decimal assumida)
          parse.field :outros_recebimento, 279..291

          # parse.field :abatimento_nao_aproveitado, 292..304
          # parse.field :valor_lancamento, 305..317
          # parse.field :indicativo_lancamento, 318..318
          # parse.field :indicador_valor, 319..319
          # parse.field :valor_ajuste, 320..331
          # :brancos, 332..341 #complemento de registro
          # :zeros, 342..389 #complemento de registro
          # :indicativo_liquidacao_parcial, 390..390 #Indicativo de Autorização de Liquidação Parcial
          # :brancos, 391..391 #complemento de registro
          # :cod_de_liquidacao, 392..393 #meio pelo qual o título foi liquidado

          # :numero_sequencial, 394..399 #numero sequencial no arquivo
          parse.field :sequencial, 394..399
        end
      end
    end
  end
end
