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
      raise ArgumentError, 'Número inválido' unless self.is_number?

      total = 0
      multiplicador = 2

      self.to_s.split(//).reverse!.each do |caracter|
        total += (caracter.to_i * multiplicador).soma_digitos
        multiplicador = multiplicador == 2 ? 1 : 2
      end

      valor = (10 - (total % 10))
      valor == 10 ? 0 : valor
    end

    # Calcula módulo 10 do Banespa.
    #
    # @return [Integer]
    # @raise  [ArgumentError] Caso não seja um número inteiro.
    def modulo_10_banespa
      raise ArgumentError, 'Número inválido' unless self.is_number?

      fatores = [7, 3, 1, 9, 7, 3, 1, 9, 7, 3]
      total = 0
      posicao = 0
      self.to_s.split(//).each do |digito|
        total += (digito.to_i * fatores[posicao]).to_s.split(//)[-1].to_i
        posicao = (posicao < (fatores.size - 1)) ? (posicao + 1) : 0
      end
      dv = 10 - total.to_s.split(//)[-1].to_i
      dv == 10 ? 0 : dv
    end

    # Calcula módulo 11 com multiplicaroes de 9 a 2 segundo a BACEN.
    #
    # @return [Integer]
    def modulo11_9to2
      total = self.multiplicador([9, 8, 7, 6, 5, 4, 3, 2])

      return (total % 11)
    end

    # Calcula módulo 11 com multiplicaroes de 2 a 9 segundo a BACEN.
    #
    # @return [Integer]
    def modulo11_2to9
      total = self.multiplicador([2, 3, 4, 5, 6, 7, 8, 9])

      valor = (11 - (total % 11))
      return [0, 10, 11].include?(valor) ? 1 : valor
    end

    # Calcula módulo 11 com multiplicaroes de 2 a 9 (Utilizado pela CAIXA - boletos SIGCB).
    #
    # @return [Integer]
    def modulo11_2to9_caixa
      total = self.multiplicador([2, 3, 4, 5, 6, 7, 8, 9])
      total = (total % 11) unless total < 11
      valor = (11 - total)
      return valor > 9 ? 0 : valor
    end

    # Calcula módulo 11 com multiplicaroes de 9 a 2 trocando retorno <b>10 por X</b>.
    #
    # @return [Integer, String] Caso resultado for 10, retorna X.
    def modulo11_9to2_10_como_x
      valor = self.modulo11_9to2
      valor == 10 ? 'X' : valor
    end

    # Calcula módulo 11 com multiplicaroes de 9 a 2 trocando retorno <b>10 por 0</b>.
    #
    # @return [Integer]
    def modulo11_9to2_10_como_zero
      valor = self.modulo11_9to2
      valor == 10 ? 0 : valor
    end

    # Verifica se String só contem caracteres numéricos.
    #
    # @return [Boolean]
    def is_number?
      self.to_s.empty? ? false : (self.to_s =~ (/\D/)).nil?
    end

    # Soma dígitos de números inteiros positivos com 2 dígitos ou mais.
    #
    # @return [Integer]
    # @example
    #  1 #=> 1
    #  11 (1+1) #=> 2
    #  13 (1+3) #=> 4
    def soma_digitos
      total = case self.to_i
                when (0..9)
                  self
                else
                  numero = self.to_s
                  total = 0
                  0.upto(numero.size-1) { |digito| total += numero[digito, 1].to_i }
                  total
              end
      total.to_i
    end

    # Faz a multiplicação de um número pelos fatores passados como parâmetro.
    #
    # @param  [Array]
    # @return [Integer]
    # @raise  [ArgumentError] Caso não seja um número inteiro.
    def multiplicador(fatores, &block)
      raise ArgumentError, 'Número inválido' unless self.is_number?

      total = 0
      multiplicador_posicao = 0

      self.to_s.split(//).reverse!.each do |caracter|
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