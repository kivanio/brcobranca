# -*- encoding: utf-8 -*-
module Brcobranca
  module Boleto
    class BancoBradesco < Base # Banco BRADESCO

      # Nova instancia do BancoBradesco
      # @param (see Brcobranca::Boleto::Base#initialize)
      def initialize(campos={})
        campos = {:carteira => "06"}.merge!(campos)
        super(campos)
      end

      # Codigo do banco emissor (3 dígitos sempre)
      def banco
        "237"
      end

      # Retorna Carteira utilizada formatada com 2 dígitos
      def carteira_formatado
        raise(ArgumentError, "A carteira informada não é válida. O BRADESCO utiliza carteira com apenas 2 dígitos.") if @carteira.to_s.size > 2
        @carteira.to_s.rjust(2,'0')
      end

      # Número seqüencial de 11 dígitos utilizado para identificar o boleto.
      def numero_documento_formatado
        @numero_documento.to_s.rjust(11,'0')
      end

      # Campo usado apenas na exibição no boleto
      def nosso_numero_boleto
        "#{self.carteira_formatado}/#{self.numero_documento_formatado}-#{self.nosso_numero_dv}"
      end

      # Campo usado apenas na exibição no boleto
      def agencia_conta_boleto
        "#{self.agencia_formatado}-#{self.agencia_dv} / #{self.conta_corrente_formatado}-#{self.conta_corrente_dv}"
      end

      # Responsável por montar uma String com 43 caracteres que será usado na criação do código de barras
      #   As posições do campo livre ficam a critério de cada Banco arrecadador, sendo que o
      #   padrão do Bradesco é:
      #   Posição Tamanho Conteúdo
      #   20 a 23 4 Agência Cedente (Sem o digito verificador, completar com zeros a esquerda quando  necessário)
      #   24 a 25 2 Carteira
      #   26 a 36 11 Número do Nosso Número(Sem o digito verificador)
      #   37 a 43 7 Conta do Cedente (Sem o digito verificador, completar com zeros a esquerda quando necessário)
      #   44 a 44 1 Zero

      def codigo_barras_segunda_parte
        "#{self.agencia_formatado}#{self.carteira_formatado}#{self.numero_documento_formatado}#{self.conta_corrente_formatado}0"
      end
    end
  end
end