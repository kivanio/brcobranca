# -*- encoding: utf-8 -*-
require 'parseline'

module Brcobranca
  module Retorno
    module Cnab240
      class Base < Brcobranca::Retorno::Base

        # Load lines
        def self.load_lines(file, options={})
          return nil if file.blank?

          codigo_banco = codigo_banco_do_arquivo(file)

          case codigo_banco
          when "756"
            Brcobranca::Retorno::Cnab240::Sicoob.load_lines(file, options)
          else
            Brcobranca::Retorno::RetornoCnab240.load_lines(file, options)
          end
        end

        # Codigo do banco lido do arquivo.
        # Registro Header [0..2]
        def self.codigo_banco_do_arquivo(file)
          arquivo = File.open(file, "r")
          header = arquivo.gets
          codigo_banco = header.blank? ? nil : header[0..2]
          arquivo.close
          codigo_banco
        end

      end
    end
  end
end
