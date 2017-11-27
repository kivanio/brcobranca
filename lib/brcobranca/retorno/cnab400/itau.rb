# -*- encoding: utf-8 -*-
require 'parseline'

module Brcobranca
  module Retorno
    module Cnab400
      # Formato de Retorno CNAB 400
      # Baseado em: http://download.itau.com.br/bankline/layout_cobranca_400bytes_cnab_itau_mensagem.pdf
      class Itau < Brcobranca::Retorno::Cnab400::Base
        extend ParseLine::FixedWidth # Extendendo parseline

        # Load lines
        def self.load_lines(file, options = {})
          default_options = { except: [1] } # por padrao ignora a primeira linha que é header
          options = default_options.merge!(options)
          super file, options
        end

        fixed_width_layout do |parse|
          # Todos os campos descritos no documento em ordem
          # identificacao do registro transacao
          parse.field :codigo_registro, 0..0
          # :codigo_de_inscricao, 1..2 # identificacao do tipo de inscrica/empresa
          # :numero_de_inscricao, 3..16 #numero de inscricao da empresa (cpf/cnpj)

          # :agencia, 17..20 #agencia mantenedora da conta
          parse.field :agencia_com_dv, 17..20 # FIXME - SEM DIV

          # :zeros, 21..22 # complemento de registro

          # :conta, 23..27 #numero da conta corrente da empresa
          # :dac, 28..28 #digito de auto conferencia ag/conta empresa
          parse.field :cedente_com_dv, 23..28

          # :brancos, 29..36 #complemento de registro
          # :uso_da_empresa, 37..61 #identificacao do titulo na empresa

          # :nosso_numero,62..69 # identificacao do titulo no banco
          parse.field :nosso_numero, 62..69

          # :brancos, 70..81 #complemento do registro

          # :carteira, 82..84 #numero da carteira
          parse.field :carteira_variacao, 82..84

          # :nosso_numero, 85..92 #identificacao do titulo no banco (novamente?)
          # :dac_nosso_numero, 93..93 #dac nosso numero
          # :brancos, 94..106 #complemento do registro

          # :carteira, 107..107 #código da carteira
          parse.field :carteira, 107..107

          parse.field :codigo_ocorrencia, 108..109

          parse.field :data_ocorrencia, 110..115

          # :n_do_documento, 116..125 # n umero do documento de cobranca (dupl, np etc)
          # :nosso_numero, 126..133 # confirmacao do numero do titulo no banco
          # :brancos, 134..145 #complemento de registro

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

          # :tarifa_de_cobranca, 175..187 #valor da despesa de cobranca (ultimos 2 digitos, virgula decimal assumida)
          parse.field :valor_tarifa, 175..187

          # :brancos, 188..213 #complemento do registro

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

          # :boleto_dda, 292..292 #indicador de boleto dda
          # :brancos, 293..294 #complemento de registro

          # :data_credito, 295..300 #data de credito desta liquidacao
          parse.field :data_credito, 295..300

          # :instr_cancelada, 301..304 # codigo da instrucao cancelada
          # :brancos , 305..310 # complemento de registro
          # :zeros, 311..323 #complemento de registro
          # :nome_do_sacado, 324..353, #nome do sacado
          # :brancos , 354..376 # complemento de registro
          # :erros_msg, 377..384 #registros rejeitados ou laegacao do sacado ou registro de mensagem informativa
          # :brancos, 385..391 #complemento de registro
          # :cod_de_liquidacao, 392..393 #meio pelo qual o título foi liquidado

          parse.field :motivo_ocorrencia, 377..384, ->(motivos) do
            motivos.scan(/.{2}/).reject(&:blank?).reject{|motivo| motivo == '00'}
          end

          # :numero_sequencial, 394..399 #numero sequencial no arquivo
          parse.field :sequencial, 394..399

          # Campos da classe base que não encontrei a relação com CNAB400
          # parse.field :tipo_cobranca, 80..80
          # parse.field :tipo_cobranca_anterior, 81..81
          # parse.field :natureza_recebimento, 86..87
          # parse.field :convenio, 31..37
          # parse.field :comando, 108..109
          # parse.field :juros_desconto, 201..213
          # parse.field :iof_desconto, 214..226
          # parse.field :desconto_concedito, 240..252
          # parse.field :outras_despesas, 279..291
          # parse.field :abatimento_nao_aproveitado, 292..304
          # parse.field :data_liquidacao, 295..300
          # parse.field :valor_lancamento, 305..317
          # parse.field :indicativo_lancamento, 318..318
          # parse.field :indicador_valor, 319..319
          # parse.field :valor_ajuste, 320..331
        end
      end
    end
  end
end
