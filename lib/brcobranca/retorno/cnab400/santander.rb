# frozen_string_literal: true
# -*- encoding: utf-8 -*-

require 'parseline'

module Brcobranca
  module Retorno
    module Cnab400
      # Formato de Retorno CNAB 400
      # Baseado em: http://app.criodigital.com/padrao/cobranca/Documentos/Layout%20Santander.pdf
      class Santander < Brcobranca::Retorno::Cnab400::Base
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

          # :numero_controle_empresa, 37..61 #numero de controle participante

          # :nosso_numero,62..69 # identificacao do titulo no banco
          parse.field :nosso_numero, 62..69

          # :brancos, 70..106 # brancos

          parse.field :carteira, 107..107

          # :cod_de_ocorrencia, 108..109 # cod de ocorrencia no banco
          parse.field :cod_de_ocorrencia, 108..109

          # :data_de_ocorrencia, 110..115 # data ocorrencia no banco (ddmmaa)
          parse.field :data_de_ocorrencia, 110..115

          # :n_do_documento, 116..125 # numero do documento de cobranca
          # :nosso_numero, 126..133 # nosso numero de novo?
          # :codigo_original_remessa, 134..135 # codigo original da remessa

          parse.field :motivos_de_ocorrencia, 134..144, ->(motivos) { motivos.scan(/.../).reject { |n| n.to_i.zero? } }

          # :brancos, 145..145 #complemento de registro

          # :vencimento, 146..151 #data de vencimento do titulo (ddmmaa)
          parse.field :data_vencimento, 146..151

          # :valor_do_titulo, 152..164 #valor nominal do titulo
          parse.field :valor_titulo, 152..164

          # :codigo_do_banco, 165..167 # numero do banco na compensacao
          parse.field :banco_recebedor, 165..167

          # :agencia_cobradora, 168..171 # agencia cobradora
          # :dac_ag_cobradora, 172..172 # dac da agencia cobradora
          parse.field :agencia_recebedora_com_dv, 168..172

          # :especie, 173..174 # especie do titulo
          parse.field :especie_documento, 173..174

          # :tarifa_de_cobranca, 175..187 #valor da despesa de cobranca
          parse.field :valor_tarifa, 175..187

          # parse.field :outras_despesas, 188..200
          # :juros_operacao_em_atraso, 201..213 # zeros?

          # :valor_do_iof, 214..226 #valor do iof a ser recolhido
          parse.field :iof, 214..226

          # :valor_abatimento, 227..239 #valor do abatimento concedido
          parse.field :valor_abatimento, 227..239

          # :descontos, 240..252 #valor do desconto concedido
          parse.field :desconto, 240..252

          # :valor_principal, 253..265 #valor lancado em conta corrente
          parse.field :valor_recebido, 253..265

          # :juros_mora_multa, 266..278 #valor de mora multa pagos pelo sacado
          parse.field :juros_mora, 266..278

          # :outros_creditos, 279..291 #valor de outros creditos
          parse.field :outros_recebimento, 279..291

          # :brancos, 292..292 #complemento de registro
          # :codigo_aceite, 293..293 #codigo de aceite
          # :brancos, 294..294 #complemento de registro

          # :data_credito, 295..300 #data de credito desta liquidacao
          parse.field :data_credito, 295..300

          # :nome_do_sacado, 302..337 #Nome do sacado
          # :identificador_complemento, 338..338 #Identificador do Complemento
          # :unidade_moeda, 339..340 #Unidade de valor moeda corrente
          # :valor_titulo_unidade, 341..353 #Valor do titulo unidade de valor
          # :valor_ioc_unidade, 354..366 #Valor do IOC outra unidade de valor
          # :valor_debito_credito, 367..379 #Valor do debito ou credito
          # :tipo_credito/debito (d/c), 380..380 #tipo credito/debito (d/c)
          # :brancos, 381..383 #Brancos
          # :complemento, 384..385 #Complemento
          # :sigla_empresa, 386..389 #Sigla da empresa no sistema
          # :brancos, 390..391 #Brancos
          # :numero_versao, 392..394 #Número da versao

          # :numero_sequencial, 394..399 #numero sequencial no arquivo
          parse.field :sequencial, 394..399
        end
      end
    end
  end
end
