module Brcobranca
  module Boleto
    module Template
      # Métodos auxiliares de montagem de template
      module Util
        # Responsável por definir a logotipo usada no template genérico,
        # retorna o caminho para o <b>logotipo</b> ou <b>false</b> caso nao consiga encontrar o logotipo.
        def monta_logo
          imagem = self.class.to_s.downcase
          File.join(File.dirname(__FILE__),'..','..','arquivos','logos',"#{imagem}.jpg")
        end
      end
    end
  end
end