# -*- encoding: utf-8 -*-
require 'parseline'

module Brcobranca
  module Retorno
    module Cnab400
      class Base < Brcobranca::Retorno::Base

        # Load lines
        def self.load_lines(file, options={})
          arquivo = File.open(file, "r")
          codigo_banco = arquivo.gets[76..78]
          arquivo.close

          case codigo_banco
          when "237"
            Brcobranca::Retorno::Cnab400::Bradesco.load_lines(file, options)

          when "341"
            Brcobranca::Retorno::Cnab400::Itau.load_lines(file, options)

          else
            warn "Banco não encontrado (#{codigo_banco}). Carregando layout antigo padrão (ITAÚ)."
            Brcobranca::Retorno::RetornoCnab400.load_lines(file, options)
          end

        end
      end
    end
  end
end
