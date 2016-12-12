# -*- encoding: utf-8 -*-
#
# @author Kivanio Barbosa
module Brcobranca
  # Métodos auxiliares
  module Util
    class Empresa
      def initialize(documento, zero = true)
        @documento = documento
        @zero = zero
      end

      # Tipo de empresa (fisica ou juridica)
      # de acordo com o documento (CPF/CNPJ)
      # 1 = CPF
      # 2 = CNPJ
      #
      # @return [String]
      # @param  [String] documento Número do documento da empresa
      # @param  [Boollean] zero Incluir zero a esquerda
      def tipo
        @tipo = @documento.somente_numeros.size <= 11 ? '1' : '2'
        @tipo = @tipo.rjust(2, '0') if @zero
        @tipo
      end
    end
  end
end
