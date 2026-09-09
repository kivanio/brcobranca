# frozen_string_literal: true

module Brcobranca
  module PessoaLookup
    # Traduz o Hash normalizado de uma fonte de dados para os atributos do
    # sacado esperados pela gem, em dois formatos:
    #
    # * +:cnab+  - campos granulares de +Brcobranca::Remessa::Pagamento+
    #   (+documento_sacado+, +nome_sacado+, +endereco_sacado+, +bairro_sacado+,
    #   +cep_sacado+, +cidade_sacado+, +uf_sacado+);
    # * +:boleto+ - atributos de +Brcobranca::Boleto::Base+ (+sacado+,
    #   +sacado_documento+, +sacado_endereco+), com o endereço achatado em uma
    #   única string.
    #
    # Uso típico:
    #
    #   fonte = Brcobranca::PessoaLookup::CpfCnpjComBrLookup.new(token: 'seu_token')
    #   resolver = Brcobranca::PessoaLookup::Resolver.new(fonte)
    #
    #   atributos = resolver.por_documento('12345678909', formato: :cnab)
    #   pagamento = Brcobranca::Remessa::Pagamento.new(atributos.merge(nosso_numero: '1', ...))
    class Resolver
      # Formatos de saída suportados.
      FORMATOS = %i[cnab boleto].freeze

      attr_reader :fonte

      # @param fonte [#consultar_cpf, #consultar_cnpj] fonte de dados.
      def initialize(fonte)
        @fonte = fonte
      end

      # Resolve um CPF.
      #
      # @param cpf [String]
      # @param formato [Symbol] +:cnab+ ou +:boleto+.
      # @return [Hash]
      def por_cpf(cpf, formato: :cnab)
        formatar(fonte.consultar_cpf(cpf), formato)
      end

      # Resolve um CNPJ.
      #
      # @param cnpj [String]
      # @param formato [Symbol] +:cnab+ ou +:boleto+.
      # @return [Hash]
      def por_cnpj(cnpj, formato: :cnab)
        formatar(fonte.consultar_cnpj(cnpj), formato)
      end

      # Resolve um documento detectando automaticamente CPF (11 dígitos
      # numéricos) ou CNPJ (14 caracteres alfanuméricos, conforme o padrão de
      # 2026). O CPF não admite letras, então um valor alfanumérico de 11
      # posições é considerado inválido em vez de ser tratado como CPF.
      #
      # @param documento [String]
      # @param formato [Symbol] +:cnab+ ou +:boleto+.
      # @return [Hash]
      def por_documento(documento, formato: :cnab)
        limpo = documento.to_s.gsub(/[^0-9A-Za-z]/, '')

        if limpo.match?(/\A\d{11}\z/)
          por_cpf(documento, formato: formato)
        elsif limpo.match?(/\A[0-9A-Za-z]{14}\z/)
          por_cnpj(documento, formato: formato)
        else
          raise DocumentoInvalido, "documento deve ter 11 (CPF) ou 14 (CNPJ) caracteres: #{documento}"
        end
      end

      private

      def formatar(dados, formato)
        case formato
        when :cnab then para_cnab(dados)
        when :boleto then para_boleto(dados)
        else
          raise ArgumentError, "formato inválido: #{formato.inspect} (use :cnab ou :boleto)"
        end
      end

      def para_cnab(dados)
        {
          documento_sacado: documento_numerico(dados[:documento]),
          nome_sacado: dados[:nome],
          endereco_sacado: linha_logradouro(dados),
          bairro_sacado: dados[:bairro],
          cep_sacado: dados[:cep],
          cidade_sacado: dados[:cidade],
          uf_sacado: dados[:uf]
        }
      end

      def para_boleto(dados)
        {
          sacado: dados[:nome],
          sacado_documento: dados[:documento],
          sacado_endereco: endereco_completo(dados)
        }
      end

      def linha_logradouro(dados)
        juntar([dados[:logradouro], dados[:numero], dados[:complemento]])
      end

      def endereco_completo(dados)
        juntar([
                 linha_logradouro(dados),
                 dados[:bairro],
                 dados[:cep],
                 dados[:cidade],
                 dados[:uf]
               ])
      end

      # O CNAB grava o documento em posições numéricas de tamanho fixo, então um
      # CNPJ alfanumérico não é representável ali e é rejeitado explicitamente.
      def documento_numerico(documento)
        texto = documento.to_s
        return texto unless texto.match?(/[^0-9]/)

        raise DocumentoInvalido,
              "documento alfanumérico (#{texto}) não cabe nos campos numéricos do CNAB; use o formato :boleto"
      end

      def juntar(partes)
        partes.map { |parte| parte.to_s.strip }.reject(&:empty?).join(', ')
      end
    end
  end
end
