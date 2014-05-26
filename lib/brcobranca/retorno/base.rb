# encoding: utf-8

module Brcobranca
  module Retorno
    class Base # Classe base para retornos bancários
      attr_accessor :agencia_com_dv
      attr_accessor :beneficiario_com_dv
      attr_accessor :convenio
      attr_accessor :nosso_numero
      attr_accessor :tipo_cobranca
      attr_accessor :tipo_cobranca_anterior
      attr_accessor :natureza_recebimento
      attr_accessor :carteira_variacao
      attr_accessor :desconto
      attr_accessor :iof
      attr_accessor :carteira
      attr_accessor :comando
      attr_accessor :data_liquidacao
      attr_accessor :data_vencimento
      attr_accessor :valor_titulo
      attr_accessor :banco_recebedor
      attr_accessor :agencia_recebedora_com_dv
      attr_accessor :especie_documento
      attr_accessor :data_credito
      attr_accessor :valor_tarifa
      attr_accessor :outras_despesas
      attr_accessor :juros_desconto
      attr_accessor :iof_desconto
      attr_accessor :valor_abatimento
      attr_accessor :desconto_concedito
      attr_accessor :valor_recebido
      attr_accessor :juros_mora
      attr_accessor :outros_recebimento
      attr_accessor :abatimento_nao_aproveitado
      attr_accessor :valor_lancamento
      attr_accessor :indicativo_lancamento
      attr_accessor :indicador_valor
      attr_accessor :valor_ajuste
      attr_accessor :sequencial
      attr_accessor :arquivo
    end
  end
end

