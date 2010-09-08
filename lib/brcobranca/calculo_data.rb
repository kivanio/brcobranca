# -*- encoding: utf-8 -*-
module Brcobranca
  # Métodos auxiliares de cálculos envolvendo <b>Datas</b>.
  module CalculoData
    # Calcula o número de dias corridos entre a <b>data base ("Fixada" em 07.10.1997)</b> e a <b>data de vencimento</b> desejado:
    #  VENCIMENTO 04/07/2000
    #  DATA BASE - 07/10/1997
    #  FATOR DE VENCIMENTO 1001
    # @return [String] contendo 4 dígitos
    def fator_vencimento
      data_base = Date.parse "1997-10-07"
      (self - data_base).to_i.to_s.rjust(4,'0')
    end

    # Mostra a data em formato <b>dia/mês/ano</b>
    def to_s_br
      self.strftime('%d/%m/%Y')
    end
    # Retorna string contendo número de dias julianos:
    #  O cálculo é feito subtraindo-se a data atual, pelo último dia válido do ano anterior,
    #  acrescentando-se o último algarismo do ano atual na quarta posição.
    #  Deve retornar string com 4 digitos.
    #  Ex. Data atual = 11/02/2009
    #     Data válida ano anterior = 31/12/2008
    #     (Data atual - Data válida ano anterior) = 42
    #     último algarismo do ano atual = 9
    #     String atual 42+9 = 429
    #     Completa zero esquerda para formar 4 digitos = "0429"
    # @return [String] contendo 4 dígitos
    def to_juliano
      ultima_data = Date.parse("#{self.year - 1}-12-31")
      ultimo_digito_ano = self.to_s[3..3]
      dias = (self - ultima_data)
      (dias.to_i.to_s + ultimo_digito_ano).rjust(4,'0')
    end
  end
end

[ Date ].each do |klass|
  klass.class_eval { include Brcobranca::CalculoData }
end