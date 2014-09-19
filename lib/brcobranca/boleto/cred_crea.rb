# -*- encoding: utf-8 -*-
module Brcobranca
  module Boleto
    class CredCrea < Base # CredCREA

      validates_length_of :agencia, :maximum => 4, :message => "deve ser menor ou igual a 4 dígitos."
      validates_length_of :conta_corrente, :maximum => 8, :message => "deve ser menor ou igual a 8 dígitos."
      validates_length_of :conta_cooperativa, :maximum => 8, :message => "deve ser menor ou igual a 8 dígitos."
      validates_length_of :carteira, :maximum => 2, :message => "deve ser menor ou igual a 2 dígitos."
      validates_length_of :convenio, :in => 4..8, :message => "não existente para este banco."

      validates_each :numero_documento do |record, attr, value|
        valor_tamanho = value.to_s.size
        registro_tamanho = record.convenio.to_s.size
        quantidade = case
                       when (valor_tamanho > 9) && (registro_tamanho == 8)
                         '9'
                       when (valor_tamanho > 10) && (registro_tamanho == 7)
                         '10'
                       when (valor_tamanho > 7) && (registro_tamanho == 4)
                         '7'
                       when (valor_tamanho > 5) && (registro_tamanho == 6) && (!record.codigo_servico)
                         '5'
                       when (valor_tamanho > 17) && (registro_tamanho == 6) && (record.codigo_servico)
                         '17'
                       else
                         nil
                     end
        record.errors.add attr, "deve ser menor ou igual a #{quantidade} dígitos." if quantidade
      end

      # Nova instancia do CredCrea
      # @param (see Brcobranca::Boleto::Base#initialize)
      def initialize(campos={})
        campos = {
            :carteira => "18",
            :codigo_servico => false,
            :especie => "R$"
        }.merge!(campos)
        super(campos)
      end

      # Codigo do banco emissor (3 dígitos sempre)
      #
      # @return [String] 3 caracteres numéricos.
      def banco
        "001"
      end

      # Carteira
      #
      # @return [String] 2 caracteres numéricos.
      def carteira=(valor)
        @carteira = valor.to_s.rjust(2,'0') if valor
      end

      # Dígito verificador do banco
      #
      # @return [String] 1 caracteres numéricos.
      def banco_dv
        self.banco.modulo11_9to2_10_como_x
      end

      # Retorna dígito verificador da agência
      #
      # @return [String] 1 caracteres numéricos.
      def agencia_dv
        self.agencia.modulo11_9to2_10_como_x
      end

      # Conta corrente
      # @return [String] 8 caracteres numéricos.
      def conta_corrente=(valor)
        @conta_corrente = valor.to_s.rjust(8,'0') if valor
      end

      # Conta corrente na cooperativa
      # @return [String] 8 caracteres numéricos.
      def conta_cooperativa=(valor)
        @conta_cooperativa = valor.to_s.rjust(8,'0') if valor
      end

      # Dígito verificador da conta corrente
      # @return [String] 1 caracteres numéricos.
      def conta_corrente_dv
        self.conta_corrente.modulo11_9to2_10_como_x
      end

      # Número seqüencial utilizado para identificar o boleto.
      #   @return [String] 9 caracteres numéricos.
      def numero_documento=(valor)
        @numero_documento = valor.to_s.rjust(9,'0') if valor
      end

      # Dígito verificador do nosso número.
      # @return [String] 1 caracteres numéricos.
      # @see CredCrea#numero_documento
      def nosso_numero_dv
        "#{self.conta_cooperativa}#{self.numero_documento}".modulo11_9to2_10_como_x
      end

      # Nosso número para exibir no boleto.
      # @return [String]
      # @example
      #  boleto.nosso_numero_boleto #=> "12387989000004042-4"
      def nosso_numero_boleto
        "#{self.conta_cooperativa}#{self.numero_documento}"
      end

      # Agência + conta corrente do cliente para exibir no boleto.
      # @return [String]
      # @example
      #  boleto.agencia_conta_boleto #=> "0548-7 / 00001448-6"
      def agencia_conta_boleto
        "#{self.agencia}-#{self.agencia_dv} / #{self.conta_corrente}-#{self.conta_corrente_dv}"
      end

      # Segunda parte do código de barras.
      # A montagem é feita baseada na quantidade de dígitos do convênio.
      # @return [String] 25 caracteres numéricos.
      def codigo_barras_segunda_parte
        case self.convenio.to_s.size
          when 8 # Nosso Número de 17 dígitos com Convenio de 8 dígitos e numero_documento de 9 dígitos
            "000000#{self.convenio}#{self.numero_documento}#{self.carteira}"
          when 7 # Nosso Número de 17 dígitos com Convenio de 7 dígitos e numero_documento de 10 dígitos
            "000000#{self.convenio}#{self.numero_documento}#{self.carteira}"
          when 6 # Convenio de 6 dígitos
            if self.codigo_servico == false
              # Nosso Número de 11 dígitos com Convenio de 6 dígitos e numero_documento de 5 dígitos
              "#{self.convenio}#{self.numero_documento}#{self.agencia}#{self.conta_corrente}#{self.carteira}"
            else
              # Nosso Número de 17 dígitos com Convenio de 6 dígitos e sem numero_documento, carteira 16 e 18
              raise "Só é permitido emitir boletos com nosso número de 17 dígitos com carteiras 16 ou 18. Sua carteira atual é #{self.carteira}" unless (["16","18"].include?(self.carteira))
              "#{self.convenio}#{self.conta_cooperativa}#{self.numero_documento}#{self.codigo_servico}"
            end
          when 4 # Nosso Número de 7 dígitos com Convenio de 4 dígitos e sem numero_documento
            "#{self.convenio}#{self.numero_documento}#{self.agencia}#{self.conta_corrente}#{self.carteira}"
        end
      end

    end
  end
end