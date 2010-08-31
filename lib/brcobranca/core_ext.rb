module Brcobranca
  # Métodos auxiliares de formatação
  module Formatacao
    # Formata como CPF
    def to_br_cpf
      self.to_s.gsub(/^(.{3})(.{3})(.{3})(.{2})$/,'\1.\2.\3-\4')
    end

    # Formata como CEP
    # @example Formata uma string ou number como CEP.
    #   "85253100".to_br_cep #=> "85253-100"
    #   85253100.to_br_cep #=> "85253-100"
    def to_br_cep
      self.to_s.gsub(/^(.{5})(.{3})$/,'\1-\2')
    end

    # Formata como CNPJ
    def to_br_cnpj
      self.to_s.gsub(/^(.{2})(.{3})(.{3})(.{4})(.{2})$/,'\1.\2.\3/\4-\5')
    end

    # Gera formatação automatica do documento baseado no tamanho do campo.
    def formata_documento
      case self.to_s.size
      when 8 then self.to_br_cep
      when 11 then self.to_br_cpf
      when 14 then self.to_br_cnpj
      else
        self
      end
    end

    # Remove caracteres que não sejam numéricos
    def somente_numeros
      self.to_s.gsub(/\D/,'')
    end

    # Monta a linha digitável padrão para todos os bancos segundo a BACEN.
    # Retorna + ArgumentError + para Codigo de Barras em branco,
    # Codigo de Barras com tamanho diferente de 44 dígitos e
    # Codigo de Barras que não tenham somente caracteres numéricos.
    #   A linha digitável será composta por cinco campos:
    #   1º campo
    #   Composto pelo código de Banco, código da moeda, as cinco primeiras posições do campo livre
    #   e o dígito verificador deste campo;
    #   2º campo
    #   Composto pelas posições 6ª a 15ª do campo livre e o dígito verificador deste campo;
    #   3º campo
    #   Composto pelas posições 16ª a 25ª do campo livre e o dígito verificador deste campo;
    #   4º campo
    #   Composto pelo dígito verificador do código de barras, ou seja, a 5ª posição do código de
    #   barras;
    #   5º campo
    #   Composto pelo fator de vencimento com 4(quatro) caracteres e o valor do documento com
    #   10(dez) caracteres, sem separadores e sem edição.
    #   Entre cada campo deverá haver espaço equivalente a 2 (duas) posições, sendo a 1ª
    #   interpretada por um ponto (.) e a 2ª por um espaço em branco.
    def linha_digitavel
      valor_inicial = self.somente_numeros
      raise ArgumentError, "Precisa conter 44 caracteres numéricos e você passou um valor com #{valor_inicial.size} caracteres" if valor_inicial.size != 44

      linha = "#{valor_inicial[0..3]}#{valor_inicial[19..23]}"
      linha << linha.modulo10.to_s
      linha << "#{valor_inicial[24..33]}#{valor_inicial[24..33].modulo10}"
      linha << "#{valor_inicial[34..43]}#{valor_inicial[34..43].modulo10}"
      linha << "#{valor_inicial[4..4]}"
      linha << "#{valor_inicial[5..18]}"
      linha.gsub(/^(.{5})(.{5})(.{5})(.{6})(.{5})(.{6})(.{1})(.{14})$/,'\1.\2 \3.\4 \5.\6 \7 \8')
    end
  end

  # métodos auxiliares de cálculos
  module Calculo
    # Método padrão para cálculo de módulo 10 segundo a BACEN.
    def modulo10
      raise ArgumentError, "Número inválido" unless self.is_number?

      total = 0
      multiplicador = 2

      self.to_s.split(//).reverse!.each do |caracter|
        total += (caracter.to_i * multiplicador).soma_digitos
        multiplicador = multiplicador == 2 ? 1 : 2
      end

      valor = (10 - (total % 10))
      valor == 10 ? 0 : valor
    end

    def modulo_10_banespa
      raise ArgumentError, "Número inválido" unless self.is_number?

      fatores = [7,3,1,9,7,3,1,9,7,3]
      total = 0
      posicao = 0
      self.to_s.split(//).each do |digito|
        total += (digito.to_i * fatores[posicao]).to_s.split(//)[-1].to_i
        posicao = (posicao < (fatores.size - 1)) ? (posicao + 1) : 0
      end
      dv = 10 - total.to_s.split(//)[-1].to_i
      dv == 10 ? 0 : dv
    end

    # Método padrão para cálculo de módulo 11 com multiplicaroes de 9 a 2 segundo a BACEN.
    # Usado no DV do Nosso Numero, Agência e Cedente.
    #  Retorna + nil + para todos os parametros que nao forem String
    #  Retorna + nil + para String em branco
    def modulo11_9to2
      total = self.multiplicador([9,8,7,6,5,4,3,2])

      return (total % 11 )
    end

    # Método padrão para cálculo de módulo 11 com multiplicaroes de 2 a 9 segundo a BACEN.
    # Usado no DV do Código de Barras.
    #  Retorna + nil + para todos os parametros que não forem String
    #  Retorna + nil + para String em branco
    def modulo11_2to9
      total = self.multiplicador([2,3,4,5,6,7,8,9])

      valor = (11 - (total % 11))
      return [0,10,11].include?(valor) ? 1 : valor
    end

    # Retorna o dígito verificador de <b>modulo 11(9-2)</b> trocando retorno <b>10 por X</b>.
    #  Usado por alguns bancos.
    def modulo11_9to2_10_como_x
      valor = self.modulo11_9to2
      valor == 10 ? "X" : valor
    end

    # Retorna o dígito verificador de <b>modulo 11(9-2)</b> trocando retorno <b>10 por 0</b>.
    #  Usado por alguns bancos.
    def modulo11_9to2_10_como_zero
      valor = self.modulo11_9to2
      valor == 10 ? 0 : valor
    end

    # Retorna true se a String só conter caracteres numéricos.
    def is_number?
      self.to_s.empty? ? false : (self.to_s =~ (/\D/)).nil?
    end

    # Soma números inteiros positivos com 2 dígitos ou mais
    # Retorna <b>0(zero)</b> caso seja impossível.
    #  Ex. 1 = 1
    #  Ex. 11 = (1+1) = 2
    #  Ex. 13 = (1+3) = 4
    def soma_digitos
      case self.to_i
      when (0..9)
        self.to_i
      else
        total = 0
        0.upto(self.to_s.size-1) {|digito| total += self.to_s[digito,1].to_i }
        total
      end
    end

    # @option fatores [Array] Número a serem usados na multiplicação
    def multiplicador(fatores)
      raise ArgumentError, "Número inválido" unless self.is_number?

      total = 0
      multiplicador_posicao = 0

      self.to_s.split(//).reverse!.each do |caracter|
        total += (caracter.to_i * fatores[multiplicador_posicao])
        multiplicador_posicao = (multiplicador_posicao < (fatores.size - 1)) ? (multiplicador_posicao + 1) : 0
      end
      total.to_i
    end
  end

  # Métodos auxiliares de limpeza.
  module Limpeza
    # Retorna uma String contendo exatamente o valor FLOAT
    def limpa_valor_moeda
      inicio, fim = self.to_s.split(/\./)
      (inicio + fim.ljust(2,'0'))
    end
  end

  # Métodos auxiliares de cálculos envolvendo <b>Datas</b>.
  module CalculoData
    # Calcula o número de dias corridos entre a <b>data base ("Fixada" em 07.10.1997)</b> e a <b>data de vencimento</b> desejado:
    #  VENCIMENTO 04/07/2000
    #  DATA BASE - 07/10/1997
    #  FATOR DE VENCIMENTO 1001
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
    def to_juliano
      ultima_data = Date.parse("#{self.year - 1}-12-31")
      ultimo_digito_ano = self.to_s[3..3]
      dias = (self - ultima_data)
      (dias.to_i.to_s + ultimo_digito_ano).rjust(4,'0')
    end
  end
end

[ String, Numeric ].each do |klass|
  klass.class_eval { include Brcobranca::Formatacao }
end

[ String, Numeric ].each do |klass|
  klass.class_eval { include Brcobranca::Calculo }
end

[ Float ].each do |klass|
  klass.class_eval { include Brcobranca::Limpeza }
end

[ Date ].each do |klass|
  klass.class_eval { include Brcobranca::CalculoData }
end