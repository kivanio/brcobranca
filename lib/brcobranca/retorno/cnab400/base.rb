# -*- encoding: utf-8 -*-
require 'parseline'

module Brcobranca
  module Retorno
    module Cnab400
      class Base < Brcobranca::Retorno::Base

        # Load lines
        def self.load_lines(file, options={})
          return nil if file.blank?

          case codigo_banco_do_arquivo(file)
          when "237"
            Brcobranca::Retorno::Cnab400::Bradesco.load_lines(file, options)

          when "341"
            Brcobranca::Retorno::Cnab400::Itau.load_lines(file, options)

          else
            warn "Banco não encontrado (#{codigo_banco}). Carregando layout antigo padrão (ITAÚ)."
            Brcobranca::Retorno::RetornoCnab400.load_lines(file, options)
          end
        end

        # Codigo do banco lido do arquivo.
        # Registro Header [76..78]
        def self.codigo_banco_do_arquivo(file)
          arquivo = File.open(file, "r")
          header = arquivo.gets
          codigo_banco = header.blank? ? nil : header[76..78]
          arquivo.close
          codigo_banco
        end

      end
    end
  end
end
