module Brcobranca
  ##
  ## Modulo de Formatacao
  ##
  module Formatacao
    # Formata como CPF
    def to_br_cpf
      (self.kind_of?(String) ? self : self.to_s).gsub(/^(.{3})(.{3})(.{3})(.{2})$/,'\1.\2.\3-\4')
    end

# Formata como CEP
    def to_br_cep
      (self.kind_of?(String) ? self : self.to_s).gsub(/^(.{5})(.{3})$/,'\1-\2')
    end

# Formata como CNPJ
    def to_br_cnpj
      (self.kind_of?(String) ? self : self.to_s).gsub(/^(.{2})(.{3})(.{3})(.{4})(.{2})$/,'\1.\2.\3/\4-\5')
    end

# Gera formatacao automatica baseado no tamanho do campo
    def formata_documento
      case (self.kind_of?(String) ? self : self.to_s).size
      when 8 then self.to_br_cep
      when 11 then self.to_br_cpf
      when 14 then self.to_br_cnpj
      else
        self
      end     
    end

# Remove caracteres que nao sejam numericos do tipo MOEDA
    def limpa_valor_moeda
      return self unless self.kind_of?(String) && self.moeda?
      self.somente_numeros
    end

# Remove caracteres que nao sejam numericos
    def somente_numeros
      return self unless self.kind_of?(String)
      self.gsub(/\D/,'')
    end

    # Completa zeros a esquerda
    # Ex. numero="123" tamanho=3 | numero="123"
    #     numero="123" tamanho=4 | numero="0123"
    #     numero="123" tamanho=5 | numero="00123"
    def zeros_esquerda(options={})
      valor_inicial = self.kind_of?(String) ? self : self.to_s
      return valor_inicial if (valor_inicial !~ /\S/)
      digitos = options[:tamanho] || valor_inicial.size

      diferenca = (digitos - valor_inicial.size)

      return valor_inicial if (diferenca <= 0)
      return (("0" * diferenca) + valor_inicial )
    end
    
     # Monta a linha digitavel padrao para todos os bancos segundo a BACEN
      # Retorna + nil + para Codigo de Barras em branco, 
      # Codigo de Barras com tamanho diferente de 44 digitos e 
      # Codigo de Barras que não tenham somente caracteres numericos 
      def linha_digitavel
        valor_inicial = self.kind_of?(String) ? self : self.to_s
        return nil if (valor_inicial !~ /\S/) || valor_inicial.size != 44 || (!valor_inicial.scan(/\D/).empty?)

        dv_1 = ("#{valor_inicial[0..3]}#{valor_inicial[19..23]}").modulo10
        campo_1_dv = "#{valor_inicial[0..3]}#{valor_inicial[19..23]}#{dv_1}"
        campo_linha_1 = "#{campo_1_dv[0..4]}.#{campo_1_dv[5..9]}"

        dv_2 = "#{valor_inicial[24..33]}".modulo10
        campo_2_dv = "#{valor_inicial[24..33]}#{dv_2}"
        campo_linha_2 = "#{campo_2_dv[0..4]}.#{campo_2_dv[5..10]}"

        dv_3 = "#{valor_inicial[34..43]}".modulo10
        campo_3_dv = "#{valor_inicial[34..43]}#{dv_3}"
        campo_linha_3 = "#{campo_3_dv[0..4]}.#{campo_3_dv[5..10]}"

        campo_linha_4 = "#{valor_inicial[4..4]}"

        campo_linha_5 = "#{valor_inicial[5..18]}"

        "#{campo_linha_1} #{campo_linha_2} #{campo_linha_3} #{campo_linha_4} #{campo_linha_5}"
      end
  end

  module Calculo
    # metodo padrao para calculo de modulo 10 segundo a BACEN
    def modulo10
      valor_inicial = self.kind_of?(String) ? self : self.to_s
      return nil if (valor_inicial !~ /\S/)

      total = 0
      multiplicador = 2

      valor_inicial.split(//).reverse!.each do |caracter|
        total += (caracter.to_i * multiplicador).soma_digitos
        multiplicador = multiplicador == 2 ? 1 : 2
      end

      valor = (10 - (total % 10))
      valor == 10 ? 0 : valor
    end

    # metodo padrao para calculo de modulo 11 com multiplicaroes de 9 a 2 segundo a BACEN
    # Usado no DV do Nosso Numero, Agencia e Cedente
    # Retorna + nil + para todos os parametros que nao forem String
    # Retorna + nil + para String em branco
    def modulo11_9to2
      valor_inicial = self.kind_of?(String) ? self : self.to_s
      return nil if (valor_inicial !~ /\S/)

      multiplicadores = [9,8,7,6,5,4,3,2]
      total = 0
      multiplicador_posicao = 0

      valor_inicial.split(//).reverse!.each do |caracter|
        multiplicador_posicao = 0 if (multiplicador_posicao == 8)
        total += (caracter.to_i * multiplicadores[multiplicador_posicao])
        multiplicador_posicao += 1
      end

      return (total % 11 )
    end

    # metodo padrao para calculo de modulo 11 com multiplicaroes de 2 a 9 segundo a BACEN
    # Usado no DV do Codigo de Barras
    # Retorna + nil + para todos os parametros que nao forem String
    # Retorna + nil + para String em branco
    def modulo11_2to9
      valor_inicial = self.kind_of?(String) ? self : self.to_s
      return nil if (valor_inicial !~ /\S/)

      multiplicadores = [2,3,4,5,6,7,8,9]
      total = 0
      multiplicador_posicao = 0

      valor_inicial.split(//).reverse!.each do |caracter|
        multiplicador_posicao = 0 if (multiplicador_posicao == 8)
        total += (caracter.to_i * multiplicadores[multiplicador_posicao])
        multiplicador_posicao += 1
      end

      valor = (11 - (total % 11))
      return [0,10,11].include?(valor) ? 1 : valor
    end
    
    # metodo para retorno de digito verificador de modulo 11  9-2 trocando retorno 10 por X
    def modulo11_9to2_10_como_x
      #calcula modulo
      valor = self.modulo11_9to2
      #retorna digito para o bb
      valor == 10 ? "X" : valor
    end

    # Soma numeros inteiros positivos com 2 digitos ou mais
    # Retorna 0(zero) para qualquer outro paramentro passado
    # Ex. 1 = 1
    #     11 = (1+1) = 2
    #     13 = (1+3) = 4
    def soma_digitos
      valor_inicial = self.kind_of?(Fixnum) ? self : self.to_i
      return 0 if valor_inicial == 0
      return valor_inicial if valor_inicial <= 9

      valor_inicial = valor_inicial.to_s
      total = 0

      0.upto(valor_inicial.size-1) {|digito| total += valor_inicial[digito,1].to_i }

      return total
    end
  end

  ##
  ## Modulo de Validacao
  ##
  module Validacao

    # Verifica se o valor e moeda
    # Ex. +1.232.33
    # Ex. -1.232.33
    # Ex. +1,232.33
    # Ex. -1,232.33
    # Ex. +1.232,33
    # Ex. -1.232,33
    # Ex. +1,232,33
    # Ex. -1,232,33
    def moeda?
      return false unless self.kind_of?(String)
      self =~ /^(\+|-)?\d+((\.|,)\d{3}*)*((\.|,)\d{2}*)$/ ? true : false
    end
  end

  module Limpeza
    # Retorna uma String contendo o valor FLOAT passado
    def limpa_valor_moeda
      return self unless self.kind_of?(Float)
      valor_inicial = self.to_s
      (valor_inicial + ("0" * (2 - valor_inicial.split(/\./).last.size ))).somente_numeros
    end
  end

  module CalculoData
    # Calcula-se o número de dias corridos entre a data base (“Fixada” em 07.10.1997) e a do
    # vencimento desejado:
    # VENCIMENTO 04/07/2000
    # DATA BASE - 07/10/1997
    # FATOR DE VENCIMENTO 1001
    def fator_vencimento
      data_base = Date.parse "1997-10-07"
      (self - data_base).to_i
    end

    def to_s_br
      self.strftime('%d/%m/%Y')
    end
  end
end

# Inclui os Modulos nas Classes Correspondentes
class String
  include Brcobranca::Formatacao
  include Brcobranca::Validacao
  include Brcobranca::Calculo
end

class Integer
  include Brcobranca::Formatacao
  include Brcobranca::Calculo
end

class Float
  include Brcobranca::Limpeza
end

class Date
  include Brcobranca::CalculoData
end