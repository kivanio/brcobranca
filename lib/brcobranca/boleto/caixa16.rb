# encoding: utf-8

# A Caixa tem dois padrões para a geração de boleto: SIGCB e SICOB.
# O SICOB foi substiuido pelo SIGCB que é implementado por esta classe.
# http://downloads.caixa.gov.br/_arquivos/cobranca_caixa_sigcb/manuais/CODIGO_BARRAS_SIGCB.PDF
#
module Brcobranca
  module Boleto
    class Caixa16 < Base # Caixa

      MODALIDADE_COBRANCA = {
        :registrada => '1',
        :sem_registro => '2'
      }

      EMISSAO_BOLETO = {
        :cedente => '4'
      }

      # Validações
      validates_length_of :carteira, :is => 2, :message => 'deve possuir 2 dígitos. (caixa16)'
      validates_length_of :convenio, :is => 5, :message => 'deve possuir 5 dígitos. (caixa16)'
      validates_length_of :numero_documento, :is => 14, :message => 'deve possuir 14 dígitos. (caixa16)'

      # Nova instância da CaixaEconomica
      # @param (see Brcobranca::Boleto::Base#initialize)
      def initialize campos = {}
        campos = {
          :carteira => "87"
        }.merge!(campos)

        campos.merge!(:convenio => campos[:convenio].rjust(5, '0')) if campos[:convenio]
        campos.merge!(:numero_documento => campos[:numero_documento].rjust(14, '0')) if campos[:numero_documento]

        super(campos)
      end

      # Código do banco emissor
      # @return [String]
      def banco; '104' end

      # Dígito verificador do código do banco em módulo 10
      # Módulo 10 de 104 é 0
      # @return [String]
      def banco_dv; '0' end

      # Nosso número, 17 dígitos
      #  1 à 2: carteira
      #  3 à 17: campo_livre
      # @return [String]
      def nosso_numero_boleto
        "#{carteira[0]}#{numero_documento}-#{nosso_numero_dv}"
      end

      # Dígito verificador do Nosso Número
      # Utiliza-se o [-1..-1] para retornar o último caracter
      # @return [String]
      def nosso_numero_dv
        "#{carteira}#{numero_documento}".modulo11_2to9_caixa.to_s
      end

      # Número da agência/código cedente do cliente para exibir no boleto.
      # @return [String]
      # @example
      #  boleto.agencia_conta_boleto #=> "1565/100000-4"
      def agencia_conta_boleto
        "#{agencia}/#{convenio}-#{convenio_dv}"
      end

      # Dígito verificador do convênio ou código do cedente
      # @return [String]
      def convenio_dv
        "#{convenio.modulo11_2to9_caixa}"
      end

      # Monta a segunda parte do código de barras.
      #  XXXXX  -> codigo do cedente/convenio
      #  AAAA -> Agência do cedente
      #  CC -> 87 # Número desta carteira
      #  NNNNN NNNNN NNNN -> Nosso número - numero sequencial do boleto 14 digitos.
      # @return [String]
      def codigo_barras_segunda_parte
        campo_livre = "#{convenio}" <<
        "#{agencia}" <<
        "#{carteira}" <<
        "#{numero_documento}"
      end

    end
  end
end
