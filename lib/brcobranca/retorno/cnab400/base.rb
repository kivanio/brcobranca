# -*- encoding: utf-8 -*-
#
require 'parseline'

module Brcobranca
  module Retorno
    module Cnab400
      class Base < Brcobranca::Retorno::Base
        # Load lines
        def self.load_lines(file, options = {})
          return nil if file.blank?

          case codigo_banco_do_arquivo(file)
          when '001' then Brcobranca::Retorno::Cnab400::BancoBrasil.load_lines(file, options)
          when '033' then Brcobranca::Retorno::Cnab400::Santander.load_lines(file, options)
          when '237' then Brcobranca::Retorno::Cnab400::Bradesco.load_lines(file, options)
          when '341' then Brcobranca::Retorno::Cnab400::Itau.load_lines(file, options)
          else Brcobranca::Retorno::RetornoCnab400.load_lines(file, options)
          end
        end

        # Codigo do banco lido do arquivo.
        # Registro Header [76..78]
        def self.codigo_banco_do_arquivo(file)
          arquivo = File.open(file, 'r')
          header = arquivo.gets
          codigo_banco = header.blank? ? nil : header[76..78]
          arquivo.close
          codigo_banco
        end
      end
    end
  end
end
