# -*- encoding: utf-8 -*-
#
module Brcobranca
  module Boleto
    class Sicoob < Base # Sicoob (Bancoob)
      validates_length_of :agencia, maximum: 4, message: 'deve ser menor ou igual a 4 dígitos.'
      validates_length_of :conta_corrente, maximum: 8, message: 'deve ser menor ou igual a 8 dígitos.'
      validates_length_of :nosso_numero, maximum: 7, message: 'deve ser menor ou igual a 7 dígitos.'
      validates_length_of :convenio, maximum: 7, message: 'deve ser menor ou igual a 7 dígitos.'
      validates_length_of :variacao, maximum: 2, message: 'deve ser menor ou igual a 2 dígitos.'
      validates_length_of :quantidade, maximum: 3, message: 'deve ser menor ou igual a 3 dígitos.'

      def initialize(campos = {})
        campos = { carteira: '1', variacao: '01', quantidade: '001' }.merge!(campos)
        super(campos)
      end

      # Codigo do banco emissor (3 dígitos sempre)
      #
      # @return [String] 3 caracteres numéricos.
      def banco
        '756'
      end

      # Dígito verificador do banco
      #
      # @return [String] 1 caractere.
      def banco_dv
        '0'
      end

      # Agência
      #
      # @return [String] 4 caracteres numéricos.
      def agencia=(valor)
        @agencia = valor.to_s.rjust(4, '0') if valor
      end

      # Convênio
      #
      # @return [String] 7 caracteres numéricos.
      def convenio=(valor)
        @convenio = valor.to_s.rjust(7, '0') if valor
      end

      # Número documento
      #
      # @return [String] 7 caracteres numéricos.
      def nosso_numero=(valor)
        @nosso_numero = valor.to_s.rjust(7, '0') if valor
      end

      # Quantidade
      #
      # @return [String] 3 caracteres numéricos.
      def quantidade=(valor)
        @quantidade = valor.to_s.rjust(3, '0') if valor
      end

      # Nosso número para exibição no boleto.
      #
      # @return [String] 8 caracteres numéricos.
      def nosso_numero_boleto
        "#{nosso_numero}#{nosso_numero_dv}"
      end

      # 3.13. Nosso número: Código de controle que permite ao Sicoob e à empresa identificar os dados da cobrança que deu origem ao boleto.
      #
      # Para o cálculo do dígito verificador do nosso número, deverá ser utilizada a fórmula abaixo:
      # Número da Cooperativa    9(4) – vide planilha "Capa" deste arquivo
      # Código do Cliente   9(10) – vide planilha "Capa" deste arquivo
      # Nosso Número   9(7) – Iniciado em 1
      #
      # Constante para cálculo  = 3197
      #
      # a) Concatenar na seqüência completando com zero à esquerda.
      #     Ex.:Número da Cooperativa  = 0001
      #           Número do Cliente  = 1-9
      #           Nosso Número  = 21
      #           000100000000190000021
      #
      # b) Alinhar a constante com a seqüência repetindo de traz para frente.
      #     Ex.: 000100000000190000021
      #          319731973197319731973
      #
      # c) Multiplicar cada componente da seqüência com o seu correspondente da constante e somar os resultados.
      #     Ex.: 1*7 + 1*3 + 9*1 + 2*7 + 1*3 = 36
      #
      # d) Calcular o Resto através do Módulo 11.
      #     Ex.: 36/11 = 3, resto = 3
      #
      # e) O resto da divisão deverá ser subtraído de 11 achando assim o DV (Se o Resto for igual a 0 ou 1 então o DV é igual a 0).
      #     Ex.: 11 – 3 = 8, então Nosso Número + DV = 21-8
      #
      def nosso_numero_dv
        "#{agencia}#{convenio.rjust(10, '0')}#{nosso_numero}".modulo11(
          reverse: false,
          multiplicador: [3, 1, 9, 7],
          mapeamento: { 10 => 0, 11 => 0 }
        ) { |t| 11 - (t % 11) }
      end

      def agencia_conta_boleto
        "#{agencia} / #{convenio}"
      end

      # Posição     Tamanho     Conteúdo
      #    20 a 20      01                 Código da carteira de cobrança - vide planilha "Capa" deste arquivo
      #    21 a 24      04                 Código da agência/cooperativa - verificar na planilha "Capa" deste arquivo
      #    25 a 26      02                 Código da modalidade - verificar na planilha "Capa" deste arquivo
      #    27 a 33      07                 Código do cedente/cliente - verificar na planilha "Capa" deste arquivo
      #    34 a 41      08                 Nosso número do boleto
      #    41 a 44      03                 Número da parcela a que o boleto se refere - "001" se parcela única
      def codigo_barras_segunda_parte
        "#{carteira}#{agencia}#{variacao}#{convenio}#{nosso_numero_boleto}#{quantidade}"
      end
    end
  end
end
