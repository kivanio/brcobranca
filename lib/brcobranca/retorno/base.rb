# encoding: utf-8
#

module Brcobranca
  module Retorno
    class Base # Classe base para retornos bancários
      attr_accessor :agencia_com_dv
      attr_accessor :agencia_sem_dv
      attr_accessor :cedente_com_dv
      attr_accessor :convenio
      attr_accessor :nosso_numero
      attr_accessor :nosso_numero_com_dv
      attr_accessor :cod_de_ocorrencia
      attr_accessor :data_de_ocorrencia
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
      attr_accessor :data_ocorrencia
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

      ###############
      # CNAB 240
      ###############

      # Código de Movimento Retorno (C044)
      #
      # Código adotado pela FEBRABAN, para identificar o tipo de movimentação
      # enviado nos registros do arquivo de retorno.
      #
      # Os códigos de movimento '02', '03', '26' e '30' estão relacionados com
      # a descrição C047-A.
      #
      # O código de movimento '28' está relacionado com a descrição C047-B.
      #
      # Os códigos de movimento '06', '09' e '17' estão relacionados com
      # a descrição C047-C.
      attr_accessor :cod_movimento_ret

      # Motivo da Ocorrência (C047)
      #
      # Código adotado pela FEBRABAN para identificar as ocorrências
      # (rejeições, tarifas, custas, liquidação e baixas) em registros detalhe
      # de títulos de cobrança.
      #
      # Poderão ser informados até cinco ocorrências distintas, incidente
      # sobre o título.
      attr_accessor :motivo_ocorrencia
    end
  end
end
