# -*- encoding: utf-8 -*-

module Brcobranca
  module Retorno
    module Cnab400
      # Formato de Retorno CNAB 400
      # Baseado em: http://www.bradesco.com.br/portal/PDF/pessoajuridica/solucoes-integradas/outros/layout-de-arquivo/cobranca/4008-524-0121-08-layout-cobranca-versao-portugues.pdf
      class Bradesco < Brcobranca::Retorno::Cnab400::Base
        extend ParseLine::FixedWidth # Extendendo parseline

        # Load lines
        def self.load_lines(file, options = {})
          default_options = { except: [1] } # por padrao ignora a primeira linha que é header
          options = default_options.merge!(options)
          super file, options
        end

        # Fixed width layout for Bradesco
        fixed_width_layout do |parse|
          # Todos os campos descritos no documento em ordem
          # :tipo_de_registro, 0..0 # identificacao do registro transacao
          # :codigo_de_inscricao, 1..2 # identificacao do tipo de inscricao/empresa
          # :numero_de_inscricao, 3..16 # numero de inscricao da empresa (cpf/cnpj)
          # :zeros, 17..19

          # Identificacao da empresa no banco
          # :zeros, 20..20
          # :carteira, 21..23
          # :agencia_sem_dv, 24..28
          # :cedente_com_dv 29..36
          parse.field :carteira, 21..23
          parse.field :agencia_sem_dv, 24..28
          parse.field :cedente_com_dv, 29..36

          # :numero_controle_empresa, 37..61, # numero de controle da empresa
          # :zeros, 62..69

          # :nosso_numero, 70..81 # identificacao do titulo no banco
          parse.field :nosso_numero, 70..81

          # :zeros, 82..91 # uso do banco
          # :zeros, 92..103 # uso do banco
          # :indicador_de_rateio, 104..104 # indicador de rateio de credito
          # :zeros, 105..106
          # :carteira, 107..107 # de novo?
          parse.field :cod_de_ocorrencia, 108..109
          # :data_de_ocorrencia, 110..115 # data de ocorrencia no banco (ddmmaa)
          # :n_do_documento, 116..125 # n umero do documento de cobranca (dupl, np etc)
          # :nosso_numero, 126..133 # confirmacao do numero do titulo no banco
          # :brancos, 134..145 # complemento de registro

          # :vencimento, 146..151 # data de vencimento do titulo (ddmmaa)
          parse.field :data_vencimento, 146..151

          # :valor_do_titulo, 152..164 # valor nominal do titulo (ultimos 2 digitos, virgula decimal assumida)
          parse.field :valor_titulo, 152..164

          # :codigo_do_banco, 165..167 # numero do banco na camara de compensacao
          parse.field :banco_recebedor, 165..167

          # :agencia_cobradora, 168..171 # agencia cobradora, ag de liquidacao ou baixa
          # :dac_ag_cobradora, 172..172 # dac da agencia cobradora
          parse.field :agencia_recebedora_com_dv, 168..172

          # :especie, 173..174 # especie do titulo
          parse.field :especie_documento, 173..174

          # :tarifa_de_cobranca, 175..187 # valor da despesa de cobranca (ultimos 2 digitos, virgula decimal assumida)
          parse.field :valor_tarifa, 175..187

          # :outras_despesas 188..200, # valor de outras despesas ou custos do protesto
          # :juros_operacao_em_atraso, 201..213 # zeros?

          # :valor_do_iof, 214..226 # valor do iof a ser recolhido (ultimos 2 digitos, virgula decimal assumida)
          parse.field :iof, 214..226

          # :valor_abatimento, 227..239 # valor do abatimento concedido (ultimos 2 digitos, virgula decimal assumida)
          parse.field :valor_abatimento, 227..239

          # :descontos, 240..252 # valor do desconto concedido (ultimos 2 digitos, virgula decimal assumida)
          parse.field :desconto, 240..252

          # :valor_recebido, 253..265 # valor lancado em conta corrente (ultimos 2 digitos, virgula decimal assumida)
          parse.field :valor_recebido, 253..265

          # :juros_mora, 266..278 # valor de mora e multa pagos pelo sacado (ultimos 2 digitos, virgula decimal assumida)
          parse.field :juros_mora, 266..278

          # :outros_creditos, 279..291 # valor de outros creditos (ultimos 2 digitos, virgula decimal assumida)
          parse.field :outros_recebimento, 279..291

          # :brancos, 292..293
          # :motivo_do_codigo_de_ocorrencia, 294..294

          # :data_credito, 295..300 # data de credito desta liquidacao
          parse.field :data_credito, 295..300

          # :origem_pagamento, 301..303
          # :brancos, 304..313
          # :cheque_bradesco, 314..317
          # :motivo_rejeicao, 318..327
          # :brancos, 328..367
          # :numero_do_cartorio, 368..369
          # :numero_do_protocolo, 370..379
          # :brancos, 380..393

          # :numero_sequencial, 394..399 # numero sequencial no arquivo
          parse.field :sequencial, 394..399
        end

        def agencia_com_dv
          "#{agencia_sem_dv}-#{agencia_sem_dv.modulo11}"
        end
      end
    end
  end
end
