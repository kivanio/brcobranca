# frozen_string_literal: true

module Brcobranca
  module Retorno
    module Cnab240
      class Base < Brcobranca::Retorno::Base
        # Load lines
        def self.load_lines(file, options = {})
          return nil unless file

          codigo_banco = codigo_banco_do_arquivo(file)

          case codigo_banco
          when "033"
            Brcobranca::Retorno::Cnab240::Santander.load_lines(file, options)
          when "341"
            Brcobranca::Retorno::Cnab240::Itau.load_lines(file, options)
          when "085"
            Brcobranca::Retorno::Cnab240::Ailos.load_lines(file, options)
          when "208"
            Brcobranca::Retorno::Cnab240::BtgPactual.load_lines(file, options)
          when "748"
            Brcobranca::Retorno::Cnab240::Sicredi.load_lines(file, options)
          when "756"
            Brcobranca::Retorno::Cnab240::Sicoob.load_lines(file, options)
          else
            Brcobranca::Retorno::RetornoCnab240.load_lines(file, options)
          end
        end

        # Codigo do banco lido do arquivo.
        # Registro Header [0..2]
        #
        # Ignora o BOM UTF-8 no inicio do arquivo (o BTG Pactual gera os
        # retornos com ele), que deslocaria o codigo do banco.
        def self.codigo_banco_do_arquivo(file)
          header = File.open(file, &:gets)
          return nil if header.blank?

          header.b.delete_prefix("\xEF\xBB\xBF".b)[0..2]
        end
      end
    end
  end
end
