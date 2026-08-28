# frozen_string_literal: true

module Brcobranca
  # Declara os metodos que a classe base espera de cada banco.
  #
  # Chamar um deles numa classe que nao o implementou levanta
  # Brcobranca::NaoImplementado com a mensagem padrao.
  #
  #   class Base
  #     extend Brcobranca::MetodosAbstratos
  #
  #     metodos_abstratos :cod_banco, :nome_banco
  #   end
  module MetodosAbstratos
    MENSAGEM = 'Sobreescreva este método na classe referente ao banco que você esta criando'

    def metodos_abstratos(*nomes)
      nomes.each do |nome|
        define_method(nome) do |*_args|
          raise Brcobranca::NaoImplementado, MENSAGEM
        end
      end
    end
  end
end
