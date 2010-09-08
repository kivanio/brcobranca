# -*- encoding: utf-8 -*-
module Brcobranca
  module Limpeza
    # Transforma Float em String preservando o 0 a direita.
    # @return [String] contendo exatamente o valor FLOAT
    def limpa_valor_moeda
      inicio, fim = self.to_s.split(/\./)
      (inicio + fim.ljust(2,'0'))
    end
  end
end

[ Float ].each do |klass|
  klass.class_eval { include Brcobranca::Limpeza }
end