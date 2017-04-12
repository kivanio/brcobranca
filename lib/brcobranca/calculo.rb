# -*- encoding: utf-8 -*-
#
# @author Kivanio Barbosa
module Brcobranca
  # Métodos auxiliares de cálculos
  module Calculo
    # Calcula módulo 10 segundo a BACEN.
    #
    # @return [Integer]
    # @raise  [ArgumentError] Caso não seja um número inteiro.
    def modulo10
      raise ArgumentError, 'Número inválido' unless is_number?

      total = 0
      multiplicador = 2

      to_s.split(//).reverse!.each do |caracter|
        total += (caracter.to_i * multiplicador).soma_digitos
        multiplicador = multiplicador == 2 ? 1 : 2
      end

      valor = (10 - (total % 10))
      valor == 10 ? 0 : valor
    end

    # Calcula o módulo 11 segundo a BACEN
    #
    # @return [Integer]
    # @raise  [ArgumentError] Caso não seja um número inteiro.
    # @param  [Hash] options Opções para o cálculo do módulo
    # @option options [Hash] :mapeamento Mapeamento do valor final. Ex: { 10 => "X" }. Padrão: {}
    # @option options [Array] :multiplicador Números a serem utilizados na multiplicação da direita para a esquerda. Padrão: [9 até 2]
    def modulo11(options = {}, &_block)
      options[:mapeamento] ||= {}
      options[:multiplicador] ||= [9, 8, 7, 6, 5, 4, 3, 2]

      total = multiplicador(fatores: options[:multiplicador], reverse: options[:reverse])
      valor = block_given? ? yield(total) : (total % 11)

      options[:mapeamento][valor] || valor
    end

    # Verifica se String só contem caracteres numéricos.
    #
    # @return [Boolean]
    def is_number?
      to_s.empty? ? false : (to_s =~ /\D/).nil?
    end

    # Soma dígitos de números inteiros positivos com 2 dígitos ou mais.
    #
    # @return [Integer]
    # @example
    #  1 #=> 1
    #  11 (-9 ) #=> 2
    #  13 (-9 ) #=> 4
    #  18 (-9 ) #=> 9
    def soma_digitos
      total = self.to_i
      total = total - 9 if total > 9
      total
    end

    # Faz a multiplicação de um número pelos fatores passados como parâmetro.
    #
    # @param  [Array]
    # @return [Integer]
    # @raise  [ArgumentError] Caso não seja um número inteiro.
    def multiplicador(options = {}, &_block)
      raise ArgumentError, 'Número inválido' unless is_number?
      raise ArgumentError, 'Fatores não podem estar em branco' unless options[:fatores]

      total = 0
      multiplicador_posicao = 0
      fatores = options[:fatores]
      numeros = options[:reverse].nil? ? to_s.split(//).reverse! : to_s.split(//)

      numeros.each do |caracter|
        fator = fatores[multiplicador_posicao]
        total += block_given? ? yield(caracter, fator) : (caracter.to_i * fator)
        multiplicador_posicao = multiplicador_posicao < (fatores.size - 1) ? (multiplicador_posicao + 1) : 0
      end
      total
    end

    # Calcula duplo dígito com modulo 10 e 11
    #
    # @return [String]
    # @raise  [ArgumentError] Caso não seja um número inteiro.
    def duplo_digito
      raise ArgumentError, 'Número inválido' unless is_number?

      digito_1 = modulo10
      digito_2 = "#{self}#{digito_1}".modulo11(multiplicador: [2, 3, 4, 5, 6, 7]) { |total| (total < 11 ? total : total % 11) }

      while digito_2 == 1
        digito_1 = if digito_1 == 9
                     0
                   else
                     digito_1 + 1
                   end

        digito_2 = "#{self}#{digito_1}".modulo11(multiplicador: [2, 3, 4, 5, 6, 7]) { |total| (total < 11 ? total : total % 11) }
      end

      digito_2 = 11 - digito_2 if digito_2 != 0

      "#{digito_1}#{digito_2}"
    end
  end
end

[String, Numeric].each do |klass|
  klass.class_eval { include Brcobranca::Calculo }
end
