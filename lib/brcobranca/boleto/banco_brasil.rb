# -*- encoding: utf-8 -*-
#
module Brcobranca
  module Boleto
    class BancoBrasil < Base # Banco do Brasil
      validates_length_of :agencia, maximum: 4, message: 'deve ser menor ou igual a 4 dígitos.'
      validates_length_of :conta_corrente, maximum: 8, message: 'deve ser menor ou igual a 8 dígitos.'
      validates_length_of :carteira, maximum: 2, message: 'deve ser menor ou igual a 2 dígitos.'
      validates_length_of :convenio, in: 4..8, message: 'não existente para este banco.'

      validates_each :nosso_numero do |record, attr, value|
        valor_tamanho = value.to_s.size
        registro_tamanho = record.convenio.to_s.size
        quantidade = if (valor_tamanho > 9) && (registro_tamanho == 8)
                       '9'
                     elsif (valor_tamanho > 10) && (registro_tamanho == 7)
                       '10'
                     elsif (valor_tamanho > 7) && (registro_tamanho == 4)
                       '7'
                     elsif (valor_tamanho > 5) && (registro_tamanho == 6) && !record.codigo_servico
                       '5'
                     elsif (valor_tamanho > 17) && (registro_tamanho == 6) && record.codigo_servico
                       '17'
                     end
        record.errors.add attr, "deve ser menor ou igual a #{quantidade} dígitos." if quantidade
      end

      # Nova instancia do BancoBrasil
      # @param (see Brcobranca::Boleto::Base#initialize)
      def initialize(campos = {})
        campos = { carteira: '18', codigo_servico: false }.merge!(campos)
        super(campos)
      end

      # Codigo do banco emissor (3 dígitos sempre)
      #
      # @return [String] 3 caracteres numéricos.
      def banco
        '001'
      end

      # Carteira
      #
      # @return [String] 2 caracteres numéricos.
      def carteira=(valor)
        @carteira = valor.to_s.rjust(2, '0') if valor
      end

      # Dígito verificador do banco
      #
      # @return [String] 1 caracteres numéricos.
      def banco_dv
        banco.modulo11(mapeamento: { 10 => 'X' })
      end

      # Retorna dígito verificador da agência
      #
      # @return [String] 1 caracteres numéricos.
      def agencia_dv
        agencia.modulo11(mapeamento: { 10 => 'X' })
      end

      # Conta corrente
      # @return [String] 8 caracteres numéricos.
      def conta_corrente=(valor)
        @conta_corrente = valor.to_s.rjust(8, '0') if valor
      end

      # Dígito verificador da conta corrente
      # @return [String] 1 caracteres numéricos.
      def conta_corrente_dv
        conta_corrente.modulo11(mapeamento: { 10 => 'X' })
      end

      # Número seqüencial utilizado para identificar o boleto.
      # (Número de dígitos depende do tipo de convênio).
      # @raise  [Brcobranca::NaoImplementado] Caso o tipo de convênio não seja suportado pelo Brcobranca.
      #
      # @overload nosso_numero
      #   Nosso Número de 17 dígitos com Convenio de 8 dígitos.
      #   @return [String] 9 caracteres numéricos.
      # @overload nosso_numero
      #   Nosso Número de 17 dígitos com Convenio de 7 dígitos.
      #   @return [String] 10 caracteres numéricos.
      # @overload nosso_numero
      #   Nosso Número de 7 dígitos com Convenio de 4 dígitos.
      #   @return [String] 4 caracteres numéricos.
      # @overload nosso_numero
      #   Nosso Número de 11 dígitos com Convenio de 6 dígitos e {#codigo_servico} false.
      #   @return [String] 5 caracteres numéricos.
      # @overload nosso_numero
      #   Nosso Número de 17 dígitos com Convenio de 6 dígitos e {#codigo_servico} true. (carteira 16 e 18)
      #   @return [String] 17 caracteres numéricos.
      def nosso_numero
        quantidade = case @convenio.to_s.size
                     when 8
                       9
                     when 7
                       10
                     when 4
                       7
                     when 6
                       codigo_servico ? 17 : 5
                     else
                       raise Brcobranca::NaoImplementado, 'Tipo de convênio não implementado.'
        end
        quantidade ? @nosso_numero.to_s.rjust(quantidade, '0') : @nosso_numero
      end

      # Dígito verificador do nosso número.
      # @return [String] 1 caracteres numéricos.
      # @see BancoBrasil#nosso_numero
      def nosso_numero_dv
        "#{convenio}#{nosso_numero}".modulo11(mapeamento: { 10 => 'X' })
      end

      # Nosso número para exibir no boleto.
      # @return [String]
      # @example
      #  boleto.nosso_numero_boleto #=> "12387989000004042-4"
      def nosso_numero_boleto
        "#{convenio}#{nosso_numero}"
      end

      # Agência + conta corrente do cliente para exibir no boleto.
      # @return [String]
      # @example
      #  boleto.agencia_conta_boleto #=> "0548-7 / 00001448-6"
      def agencia_conta_boleto
        "#{agencia}-#{agencia_dv} / #{conta_corrente}-#{conta_corrente_dv}"
      end

      # Segunda parte do código de barras.
      # A montagem é feita baseada na quantidade de dígitos do convênio.
      # @return [String] 25 caracteres numéricos.
      def codigo_barras_segunda_parte
        case convenio.to_s.size
        when 8 # Nosso Número de 17 dígitos com Convenio de 8 dígitos e nosso_numero de 9 dígitos
          "000000#{convenio}#{nosso_numero}#{carteira}"
        when 7 # Nosso Número de 17 dígitos com Convenio de 7 dígitos e nosso_numero de 10 dígitos
          "000000#{convenio}#{nosso_numero}#{carteira}"
        when 6 # Convenio de 6 dígitos
          if codigo_servico == false
            # Nosso Número de 11 dígitos com Convenio de 6 dígitos e nosso_numero de 5 dígitos
            "#{convenio}#{nosso_numero}#{agencia}#{conta_corrente}#{carteira}"
          else
            # Nosso Número de 17 dígitos com Convenio de 6 dígitos e sem nosso_numero, carteira 16 e 18
            raise "Só é permitido emitir boletos com nosso número de 17 dígitos com carteiras 16 ou 18. Sua carteira atual é #{carteira}" unless %w(16 18).include?(carteira)
            "#{convenio}#{nosso_numero}21"
          end
        when 4 # Nosso Número de 7 dígitos com Convenio de 4 dígitos e sem nosso_numero
          "#{convenio}#{nosso_numero}#{agencia}#{conta_corrente}#{carteira}"
        end
      end
    end
  end
end
