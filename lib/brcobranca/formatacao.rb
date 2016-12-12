# -*- encoding: utf-8 -*-
#
# @author Kivanio Barbosa
module Brcobranca
  # Métodos auxiliares de formatação
  module Formatacao
    # Formata como CPF
    #
    # @return [String]
    # @example
    #  "12345678901".to_br_cpf #=> 123.456.789-01
    def to_br_cpf
      somente_numeros.gsub(/^(.{3})(.{3})(.{3})(.{2})$/, '\1.\2.\3-\4')
    end

    # Formata como CEP
    #
    # @return [String]
    # @example
    #   "85253100".to_br_cep #=> "85253-100"
    #   85253100.to_br_cep #=> "85253-100"
    def to_br_cep
      somente_numeros.gsub(/^(.{5})(.{3})$/, '\1-\2')
    end

    # Formata como CNPJ
    #
    # @return [String]
    # @example
    #  "12345678000901".to_br_cnpj #=> 12.345.678/0009-01
    def to_br_cnpj
      somente_numeros.gsub(/^(.{2})(.{3})(.{3})(.{4})(.{2})$/, '\1.\2.\3/\4-\5')
    end

    # Gera formatação automática do documento baseado no tamanho do campo.
    #
    # @return [String] Retorna a mesma caso não encontre o formato adequado.
    # @example
    #  "12345678000901".formata_documento #=> 12.345.678/0009-01
    #  "85253100".formata_documento #=> "85253-100"
    #  "12345678901".formata_documento #=> 123.456.789-01
    #  "12345".formata_documento #=> 12345
    def formata_documento
      case somente_numeros.size
      when 8 then to_br_cep
      when 11 then to_br_cpf
      when 14 then to_br_cnpj
      else
        self
      end
    end

    # Remove caracteres que não sejam numéricos.
    #
    # @return [String]
    # @example
    #   1a23e45+".somente_numeros #=> 12345
    def somente_numeros
      to_s.gsub(/\D/, '')
    end

    # Monta a linha digitável padrão para todos os bancos segundo a BACEN.
    #
    # A linha digitável será composta por cinco campos:<br/>
    # <b>1º campo</b>: <br/>
    # Composto pelo código de Banco, código da moeda, as cinco primeiras posições do campo livre
    # e o dígito verificador deste campo.<br/>
    # <b>2º campo</b>: <br/>
    # Composto pelas posições 6ª a 15ª do campo livre e o dígito verificador deste campo.<br/>
    # <b>3º campo</b>: <br/>
    # Composto pelas posições 16ª a 25ª do campo livre e o dígito verificador deste campo.<br/>
    # <b>4º campo</b>: <br/>
    # Composto pelo dígito verificador do código de barras, ou seja, a 5ª posição do código de barras.<br/>
    # <b>5º campo</b>: <br/>
    # Composto pelo fator de vencimento com 4(quatro) caracteres e o valor do documento com
    # 10(dez) caracteres, sem separadores e sem edição.<br/>
    #
    # @return [String]
    # @raise  [ArgumentError] Caso não seja um número de 44 dígitos.
    # @example
    #  "00192376900000135000000001238798777770016818".linha_digitavel #=> "00190.00009 01238.798779 77700.168188 2 37690000013500"
    def linha_digitavel
      if self =~ /^(\d{4})(\d{1})(\d{14})(\d{5})(\d{10})(\d{10})$/
        linha = Regexp.last_match[1]
        linha << Regexp.last_match[4]
        linha << linha.modulo10.to_s
        linha << Regexp.last_match[5]
        linha << Regexp.last_match[5].modulo10.to_s
        linha << Regexp.last_match[6]
        linha << Regexp.last_match[6].modulo10.to_s
        linha << Regexp.last_match[2]
        linha << Regexp.last_match[3]
        linha.gsub(/^(.{5})(.{5})(.{5})(.{6})(.{5})(.{6})(.{1})(.{14})$/, '\1.\2 \3.\4 \5.\6 \7 \8')
      else
        raise ArgumentError, "#{self} Precisa conter 44 caracteres numéricos."
      end
    end
  end
end

[String, Numeric].each do |klass|
  klass.class_eval { include Brcobranca::Formatacao }
end
