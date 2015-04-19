# -*- encoding: utf-8 -*-
# @author Kivanio Barbosa
module Brcobranca
  # Métodos auxiliares de cálculos
  module Calculo
    # Calcula módulo 10 segundo a BACEN.
    #
    # @return [Integer]
    # @raise  [ArgumentError] Caso não seja um número inteiro.
    def modulo10
      fail ArgumentError, 'Número inválido' unless self.is_number?

      total = 0
      multiplicador = 2

      to_s.split(//).reverse!.each do |caracter|
        total += (caracter.to_i * multiplicador).soma_digitos
        multiplicador = multiplicador == 2 ? 1 : 2
      end

      valor = (10 - (total % 10))
      valor == 10 ? 0 : valor
    end

    # Calcula módulo 11 com multiplicaroes de 9 a 2 segundo a BACEN.
    #
    # @return [Integer]
    def modulo11_9to2
      total = multiplicador([9, 8, 7, 6, 5, 4, 3, 2])

      (total % 11)
    end

    # Calcula módulo 11 com multiplicaroes de 2 a 9 segundo a BACEN.
    #
    # @return [Integer]
    def modulo11_2to9
      total = multiplicador([2, 3, 4, 5, 6, 7, 8, 9])

      valor = (11 - (total % 11))
      [0, 10, 11].include?(valor) ? 1 : valor
    end

    # Calcula módulo 11 com multiplicadores de 2 a 9 e 2 a 5 (Utilizado pelo Santander).
    #
    # @return [Integer]
    def modulo11_santander
      return 0 if to_i == 0

      somatorio = 0
      multiplicadores = [2, 3, 4, 5, 6, 7, 8, 9, 2, 3, 4, 5]
      base = "#{rjust(12, '0')}".reverse
      index = 0

      base.each_char do |_char|
        somatorio += base[index].to_i * multiplicadores[index].to_i
        index += 1
      end

      resto = somatorio % 11
      return 1 if resto == 10
      return 0 if resto == 1 || resto == 0
      11 - resto
    end

    # Calcula módulo 11 com multiplicadores de 2, 7 a 2, e 7 a 2 (Utilizado pelo Bradesco).
    #
    # @return [Integer, String] Caso o resto seja 1, retorna P

    def modulo11_bradesco
      somatorio = 0
      multiplicadores = [2, 7, 6, 5, 4, 3, 2, 7, 6, 5, 4, 3, 2]
      index = 0

      each_char do |_char|
        somatorio += self[index].to_i * multiplicadores[index]
        index += 1
      end

      resto = somatorio % 11
      return 0 if resto == 0
      return 'P' if resto == 1
      11 - resto
    end

    # Calcula módulo 11 com multiplicaroes de 2 a 9 (Utilizado pela CAIXA - boletos SIGCB).
    #
    # @return [Integer]
    def modulo11_2to9_caixa
      total = multiplicador([2, 3, 4, 5, 6, 7, 8, 9])
      total = (total % 11) unless total < 11
      valor = (11 - total)
      valor > 9 ? 0 : valor
    end

    # Calcula módulo 11 com multiplicaroes de 9 a 2 trocando retorno <b>10 por X</b>.
    #
    # @return [Integer, String] Caso resultado for 10, retorna X.
    def modulo11_9to2_10_como_x
      valor = modulo11_9to2
      valor == 10 ? 'X' : valor
    end

    # Calcula módulo 11 com multiplicaroes de 9 a 2 trocando retorno <b>10 por 0</b>.
    #
    # @return [Integer]
    def modulo11_9to2_10_como_zero
      valor = modulo11_9to2
      valor == 10 ? 0 : valor
    end

    # Verifica se String só contem caracteres numéricos.
    #
    # @return [Boolean]
    def is_number?
      to_s.empty? ? false : (to_s =~ (/\D/)).nil?
    end

    # Soma dígitos de números inteiros positivos com 2 dígitos ou mais.
    #
    # @return [Integer]
    # @example
    #  1 #=> 1
    #  11 (1+1) #=> 2
    #  13 (1+3) #=> 4
    def soma_digitos
      total = case to_i
      when (0..9)
        self
      else
        numero = to_s
        total = 0
        0.upto(numero.size - 1) { |digito| total += numero[digito, 1].to_i }
        total
      end
      total.to_i
    end

    # Faz a multiplicação de um número pelos fatores passados como parâmetro.
    #
    # @param  [Array]
    # @return [Integer]
    # @raise  [ArgumentError] Caso não seja um número inteiro.
    def multiplicador(fatores, &_block)
      fail ArgumentError, 'Número inválido' unless self.is_number?

      total = 0
      multiplicador_posicao = 0

      to_s.split(//).reverse!.each do |caracter|
        fator = fatores[multiplicador_posicao]
        total += if block_given?
                   yield(caracter, fator)
        else
          (caracter.to_i * fator)
        end
        multiplicador_posicao = (multiplicador_posicao < (fatores.size - 1)) ? (multiplicador_posicao + 1) : 0
      end
      total
    end
  end
end

[String, Numeric].each do |klass|
  klass.class_eval { include Brcobranca::Calculo }
end
