# frozen_string_literal: true

module Brcobranca
  module Retorno
    # Classe base para retornos bancários
    class Base
      attr_accessor :codigo_registro, :agencia_com_dv, :agencia_sem_dv, :cedente_com_dv, :convenio, :nosso_numero,
                    :documento_numero, :tipo_cobranca, :tipo_cobranca_anterior, :natureza_recebimento, :carteira_variacao, :desconto, :iof, :carteira, :comando, :data_liquidacao, :data_vencimento, :valor_titulo, :banco_recebedor, :agencia_recebedora_com_dv, :especie_documento, :codigo_ocorrencia, :motivo_ocorrencia, :data_ocorrencia, :data_credito, :valor_tarifa, :outras_despesas, :juros_desconto, :iof_desconto, :valor_abatimento, :desconto_concedito, :valor_recebido, :juros_mora, :outros_recebimento, :abatimento_nao_aproveitado, :valor_lancamento, :indicativo_lancamento, :indicador_valor, :valor_ajuste, :sequencial, :arquivo

      # Campos especificos para cobranca hibrida
      attr_accessor :tipo_chave_dict,
                    :codigo_chave_dict,
                    :txid

      # Campos do Split Payment (IBS/CBS) dos registros opcionais Segmento X-03
      # e X-04 do arquivo de retorno (Layout Padrao Febraban 240 posicoes V11.0,
      # 11/09/2026) - veja Brcobranca::Retorno::Cnab240::SegmentoSplitPayment.
      attr_accessor :identificacao_registro_opcional,
                    :documento_fiscal,
                    :valor_cbs_informado, :valor_ibs_informado,
                    :valor_cbs_corrigido, :valor_ibs_corrigido,
                    :valor_cbs_em_aberto, :valor_ibs_em_aberto,
                    :valor_cbs_segregado, :valor_ibs_segregado,
                    # Segmento X-03
                    :id_split, :tipo_id_split,
                    # Segmento X-04
                    :valor_pago_ausente_split,
                    :valor_repassado_novo_titular, :valor_residual
    end
  end
end
