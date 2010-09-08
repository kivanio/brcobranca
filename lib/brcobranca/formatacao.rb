# -*- encoding: utf-8 -*-
module Brcobranca
  # Métodos auxiliares de formatação
  module Formatacao
    # Formata como CPF
    def to_br_cpf
      self.to_s.gsub(/^(.{3})(.{3})(.{3})(.{2})$/,'\1.\2.\3-\4')
    end

    # Formata como CEP
    # @example Formata uma string ou number como CEP.
    #   "85253100".to_br_cep #=> "85253-100"
    #   85253100.to_br_cep #=> "85253-100"
    def to_br_cep
      self.to_s.gsub(/^(.{5})(.{3})$/,'\1-\2')
    end

    # Formata como CNPJ
    def to_br_cnpj
      self.to_s.gsub(/^(.{2})(.{3})(.{3})(.{4})(.{2})$/,'\1.\2.\3/\4-\5')
    end

    # Gera formatação automatica do documento baseado no tamanho do campo.
    def formata_documento
      case self.to_s.size
      when 8 then self.to_br_cep
      when 11 then self.to_br_cpf
      when 14 then self.to_br_cnpj
      else
        self
      end
    end

    # Remove caracteres que não sejam numéricos
    def somente_numeros
      self.to_s.gsub(/\D/,'')
    end

    # Monta a linha digitável padrão para todos os bancos segundo a BACEN.
    # Retorna + ArgumentError + para Codigo de Barras em branco,
    # Codigo de Barras com tamanho diferente de 44 dígitos e
    # Codigo de Barras que não tenham somente caracteres numéricos.
    #   A linha digitável será composta por cinco campos:
    #   1º campo
    #   Composto pelo código de Banco, código da moeda, as cinco primeiras posições do campo livre
    #   e o dígito verificador deste campo;
    #   2º campo
    #   Composto pelas posições 6ª a 15ª do campo livre e o dígito verificador deste campo;
    #   3º campo
    #   Composto pelas posições 16ª a 25ª do campo livre e o dígito verificador deste campo;
    #   4º campo
    #   Composto pelo dígito verificador do código de barras, ou seja, a 5ª posição do código de
    #   barras;
    #   5º campo
    #   Composto pelo fator de vencimento com 4(quatro) caracteres e o valor do documento com
    #   10(dez) caracteres, sem separadores e sem edição.
    #   Entre cada campo deverá haver espaço equivalente a 2 (duas) posições, sendo a 1ª
    #   interpretada por um ponto (.) e a 2ª por um espaço em branco.
    def linha_digitavel
      valor_inicial = self.somente_numeros
      raise ArgumentError, "Precisa conter 44 caracteres numéricos e você passou um valor com #{valor_inicial.size} caracteres" if valor_inicial.size != 44

      linha = "#{valor_inicial[0..3]}#{valor_inicial[19..23]}"
      linha << linha.modulo10.to_s
      linha << "#{valor_inicial[24..33]}#{valor_inicial[24..33].modulo10}"
      linha << "#{valor_inicial[34..43]}#{valor_inicial[34..43].modulo10}"
      linha << "#{valor_inicial[4..4]}"
      linha << "#{valor_inicial[5..18]}"
      linha.gsub(/^(.{5})(.{5})(.{5})(.{6})(.{5})(.{6})(.{1})(.{14})$/,'\1.\2 \3.\4 \5.\6 \7 \8')
    end
  end
end

[ String, Numeric ].each do |klass|
  klass.class_eval { include Brcobranca::Formatacao }
end