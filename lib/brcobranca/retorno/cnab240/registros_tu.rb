# frozen_string_literal: true

module Brcobranca
  module Retorno
    module Cnab240
      # Carrega retornos CNAB 240 formados por pares de registros T e U.
      #
      # O registro CNAB 240 usa dois tipos de registro que juntos formam um
      # retorno: o T, com os dados gerais da transacao, e o U, com os valores.
      # Os bancos que seguem esse padrao sem particularidades apenas estendem
      # este modulo; cada um define a propria classe Line com o layout e as
      # listas REGISTRO_T_FIELDS e REGISTRO_U_FIELDS.
      module RegistrosTU
        # Regex para remocao de headers e trailers alem de registros
        # diferentes de T ou U
        REGEX_DE_EXCLUSAO_DE_REGISTROS_NAO_T_OU_U = /^((?!^.{7}3.{5}[T|U].*$).)*$/.freeze

        def load_lines(file, options = {})
          default_options = { except: REGEX_DE_EXCLUSAO_DE_REGISTROS_NAO_T_OU_U }
          options = default_options.merge!(options)

          self::Line.load_lines(file, options).each_slice(2).reduce([]) do |retornos, cnab_lines|
            retornos << generate_retorno_based_on_cnab_lines(cnab_lines)
          end
        end

        def generate_retorno_based_on_cnab_lines(cnab_lines)
          retorno = new
          cnab_lines.each do |line|
            campos = line.tipo_registro == 'T' ? self::Line::REGISTRO_T_FIELDS : self::Line::REGISTRO_U_FIELDS
            campos.each { |attr| retorno.send(:"#{attr}=", line.send(attr)) }
          end
          retorno
        end
      end
    end
  end
end
