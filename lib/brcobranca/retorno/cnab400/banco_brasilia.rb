# -*- encoding: utf-8 -*-
require 'parseline'

module Brcobranca
  module Retorno
    module Cnab400
      # Formato de Retorno CNAB 400
      class BancoBrasilia < Brcobranca::Retorno::Base
        extend ParseLine::FixedWidth

        def self.load_lines(file, options = {})
          default_options = { except: [1] } # por padrao ignora a primeira linha que é header
          options = default_options.merge!(options)

          super file, options
        end

        fixed_width_layout do |parse|
          # Todos os campos descritos no documento em ordem
          # :tipo_de_registro, 0..0 # identificacao do registro transacao
          parse.field :codigo_registro, 0..0

          # :codigo_de_inscricao, 1..2 # identificacao do tipo de inscricao/empresa
          # :numero_de_inscricao, 3..16 # numero de inscricao da empresa (cpf/cnpj)
          # :zeros, 17..19

          # Identificacao da empresa no banco
          # :zeros, 20..20
          parse.field :cedente_com_dv, 20..36

          # :numero_controle_empresa, 37..61, # numero de controle da empresa
          # :zeros, 62..69

          # :nosso_numero, 62..69 # identificacao do titulo no banco
          parse.field :nosso_numero, 70..81

          # :zeros, 82..91 # uso do banco
          # :zeros, 92..103 # uso do banco
          # :indicador_de_rateio, 104..104 # indicador de rateio de credito
          # :zeros, 105..106
          # :carteira, 107..107 # de novo?
          parse.field :codigo_ocorrencia, 108..109
          parse.field :data_ocorrencia, 110..117
          # :nosso_numero, 128..133 # confirmacao do numero do titulo no banco
          # :brancos, 134..145 # complemento de registro

          parse.field :data_vencimento, 148..155
          parse.field :valor_titulo, 156..168
          parse.field :banco_recebedor, 169..171

          # :agencia_cobradora, 168..171 # agencia cobradora, ag de liquidacao ou baixa
          # :dac_ag_cobradora, 172..172 # dac da agencia cobradora
          # :agencia_recebedora_com_dv, 168..172

          parse.field :especie_documento, 177..178
          parse.field :valor_tarifa, 179..191

          # :outras_despesas 188..200, # valor de outras despesas ou custos do protesto
          # :juros_operacao_em_atraso, 201..213 # zeros?

          parse.field :iof, 218..230
          parse.field :valor_abatimento, 231..243
          parse.field :desconto, 244..256
          parse.field :valor_recebido, 257..269
          parse.field :outros_recebimento, 283..295

          # :brancos, 292..293
          # :motivo_do_codigo_de_ocorrencia, 294..294

          # :data_credito, 295..300 # data de credito desta liquidacao
          parse.field :data_credito, 299..306

          # :origem_pagamento, 301..303
          # :brancos, 304..313
          # :cheque_bradesco, 314..317
          # :motivo_rejeicao, 318..327
          # :brancos, 328..367
          # :numero_do_cartorio, 368..369
          # :numero_do_protocolo, 370..379
          # :brancos, 380..393

          parse.field :motivo_ocorrencia, 364..393

          parse.field :sequencial, 394..399
        end
      end
    end
  end
end
