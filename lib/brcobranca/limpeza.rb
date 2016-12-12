# -*- encoding: utf-8 -*-
#
module Brcobranca
  module Limpeza
    # Transforma Float em String preservando o zero a direita.
    #
    # @return [String]
    # @example
    #  1.9  #=> 190
    #  1.93 #=> 193
    def limpa_valor_moeda
      inicio, fim = to_s.split(/\./)
      (inicio + fim.ljust(2, '0'))
    end
  end
end

[Float, String].each do |klass|
  klass.class_eval { include Brcobranca::Limpeza }
end
