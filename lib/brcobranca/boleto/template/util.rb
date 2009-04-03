module Brcobranca
  module Boleto
    module Template
      # Métodos auxiliares de montagem de template
      module Util
        # Responsável por definir a logotipo usada no template genérico, 
        # retorna o caminho para o <b>logotipo</b> ou <b>false</b> caso nao consiga encontrar o logotipo
        def monta_logo
          case self.class.to_s
          when "BancoBrasil"
            imagem = 'bb.jpg'
          when "BancoItau"
            imagem = 'itau.jpg'
          when "BancoHsbc"
            imagem = 'hsbc.jpg'
          else
            return false
          end
          File.join(File.dirname(__FILE__),'..','..','arquivos','logos',imagem)
        end
      end
    end
  end
end