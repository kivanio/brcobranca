module Brcobranca
  # Métodos auxiliares de formatação de strings
  module FormatacaoString

    # Formata o tamanho da string
    # para o tamanho passado
    # se a string for menor, adiciona espacos a direita
    # se a string for maior, trunca para o num. de caracteres
    #
    def format_size size
      if self.size > size
        return self.truncate(size, omission: '')
      else
        return self.ljust(size, ' ')
      end
    end
  end
end

[String].each do |klass|
  klass.class_eval { include Brcobranca::FormatacaoString }
end