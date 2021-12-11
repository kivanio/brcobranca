# frozen_string_literal: true

module Brcobranca
  module Retorno
    # Classe base para retornos bancários
    class Base
      attr_accessor :codigo_registro, :agencia_com_dv, :agencia_sem_dv, :cedente_com_dv, :convenio, :nosso_numero,
                    :documento_numero, :tipo_cobranca, :tipo_cobranca_anterior, :natureza_recebimento, :carteira_variacao, :desconto, :iof, :carteira, :comando, :data_liquidacao, :data_vencimento, :valor_titulo, :banco_recebedor, :agencia_recebedora_com_dv, :especie_documento, :codigo_ocorrencia, :motivo_ocorrencia, :data_ocorrencia, :data_credito, :valor_tarifa, :outras_despesas, :juros_desconto, :iof_desconto, :valor_abatimento, :desconto_concedito, :valor_recebido, :juros_mora, :outros_recebimento, :abatimento_nao_aproveitado, :valor_lancamento, :indicativo_lancamento, :indicador_valor, :valor_ajuste, :sequencial, :arquivo
    end
  end
end
