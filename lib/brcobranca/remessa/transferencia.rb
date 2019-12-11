# -*- encoding: utf-8 -*-
module Brcobranca
  module Remessa
    class Transferencia < Brcobranca::Remessa::Pagamento

      # Código da Câmara Centralizadora
      # Código adotado pela FEBRABAN, para identificar qual Câmara de Centralizadora será responsável pelo processamento dos
      # pagamentos.
      # Preencher com o código da Câmara Centralizadora para envio do DOC. Domínio:
      # '018' = TED (STR, CIP)
      # '700' = DOC (COMPE)
      # '888' = TED (STR/CIP)
      # <b>REQUERIDO</b>: camara_centralizadora
      attr_accessor :camara_centralizadora
      # '01' - credito em conta corrente
      # '05' - credito em conta poupanca
      # '03' - TED
      # <b>REQUERIDO</b>: camara_centralizadora
      attr_accessor :forma_lancamento
      # <b>REQUERIDO</b>: banco do favorecido
      attr_accessor :banco
      # <b>REQUERIDO</b>: agencia do favorecido
      attr_accessor :agencia
      # <b>REQUERIDO</b>: conta do favorecido
      attr_accessor :conta
      # <b>REQUERIDO</b>: digito conta do favorecido
      attr_accessor :digito_conta
      # <b>REQUERIDO</b>: conta de conta CC ou PP
      attr_accessor :tipo_conta

      validates_length_of :banco, maximum: 3, message: 'deve ter 3 dígitos.'
      validates_length_of :agencia, maximum: 5, message: 'deve ter 5 dígitos.'
      validates_length_of :conta, maximum: 12, message: 'deve ter 12 dígitos.'
      validates_length_of :digito_conta, maximum: 1, message: 'deve ter 1 dígitos.'
      validates_length_of :tipo_conta, maximum: 2, message: 'deve ter 2 dígitos.'

      def digito_agencia
        # utilizando a agencia com 4 digitos
        # para calcular o digito
        agencia.modulo11(mapeamento: { 10 => 'X' }).to_s
      end

      def codigo_finalidade
        "00010#{tipo_conta.rjust(2, 'C')}"
      end

      def info_conta
        # CAMPO                  TAMANHO
        # banco                  3
        # agencia                5
        # digito agencia         1
        # conta corrente         12
        # digito conta           1
        # digito agencia/conta   1
        "#{banco.rjust(3, '0')}#{agencia.rjust(5, '0')}#{digito_agencia}#{conta.rjust(12, '0')}#{digito_conta} "
      end
    end
  end
end
