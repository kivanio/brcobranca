# -*- encoding: utf-8 -*-
module Brcobranca
  module Boleto
    class BancoBrasil < Base # Banco do Brasil

      validates_length_of :agencia, :maximum => 4, :message => "deve ser menor ou igual a 4 dígitos."
      validates_length_of :convenio, :in => 4..8, :message => "não existente para este banco."

      # Nova instancia do BancoBrasil
      # @param (see Brcobranca::Boleto::Base#initialize)
      def initialize(campos={})
        campos = {:carteira => "18", :codigo_servico => false}.merge!(campos)
        super(campos)
      end

      # Codigo do banco emissor (3 dígitos sempre)
      def banco
        "001"
      end

      # Retorna Carteira utilizada formatada com 2 dígitos
      def carteira_formatado
        raise(ArgumentError, "A carteira informada não é válida. O Banco do Brasil utiliza carteira com apenas 2 dígitos.") if @carteira.to_s.size > 2
        @carteira.to_s.rjust(2,'0')
      end

      # Retorna digito verificador do banco, calculado com modulo11 de 9 para 2, porem em caso de resultado ser 10, usa-se 'X'
      def banco_dv
        self.banco.modulo11_9to2_10_como_x
      end

      # Retorna digito verificador da agencia, calculado com modulo11 de 9 para 2, porem em caso de resultado ser 10, usa-se 'X'
      def agencia_dv
        self.agencia.modulo11_9to2_10_como_x
      end

      # Retorna número da conta corrente formatado
      def conta_corrente_formatado
        @conta_corrente.to_s.rjust(8,'0')
      end

      # Retorna digito verificador da conta corrente, calculado com modulo11 de 9 para 2, porem em caso de resultado ser 10, usa-se 'X'
      def conta_corrente_dv
        self.conta_corrente_formatado.modulo11_9to2_10_como_x
      end

      # Número seqüencial utilizado para identificar o boleto (Número de dígitos depende do tipo de convênio).
      def numero_documento_formatado
        case @convenio.to_s.size
        when 8 # Nosso Numero de 17 dígitos com Convenio de 8 dígitos e numero_documento de 9 dígitos
          raise ArgumentError, "Com convênio de 8 dígitos, somente permite-se até 9 dígitos no numero_documento. O seu está com #{@numero_documento.size} dígitos." if @numero_documento.to_s.size > 9
          @numero_documento.to_s.rjust(9,'0')
        when 7 # Nosso Numero de 17 dígitos com Convenio de 7 dígitos e numero_documento de 10 dígitos
          raise ArgumentError, "Com convênio de 7 dígitos, somente permite-se até 10 dígitos no numero_documento. O seu está com #{@numero_documento.size} dígitos." if @numero_documento.to_s.size > 10
          @numero_documento.to_s.rjust(10,'0')
        when 4 # Nosso Numero de 7 dígitos com Convenio de 4 dígitos e sem numero_documento
          raise ArgumentError, "Com convênio de 4 dígitos, somente permite-se até 7 dígitos no numero_documento. O seu está com #{@numero_documento.size} dígitos." if @numero_documento.to_s.size > 7
          @numero_documento.to_s.rjust(7,'0')
        when 6 # Convenio de 6 dígitos
          if self.codigo_servico == false
            # Nosso Numero de 11 dígitos com Convenio de 6 dígitos e numero_documento de 5 digitos
            raise ArgumentError, "Com convênio de 6 dígitos, somente permite-se até 5 dígitos no numero_documento. Para emitir boletos com nosso numero de 17 dígitos, coloque o atributo codigo_servico=true. O seu está com #{@numero_documento.size} dígitos." if @numero_documento.to_s.size > 5
            @numero_documento.to_s.rjust(5,'0')
          else
            # Nosso Numero de 17 dígitos com Convenio de 6 dígitos e sem numero_documento, carteira 16 e 18
            raise ArgumentError, "Com convênio de 6 dígitos, somente permite-se até 17 dígitos no numero_documento. O seu está com #{@numero_documento.size} dígitos." if (@numero_documento.to_s.size > 17)
            @numero_documento.to_s.rjust(17,'0')
          end
        else
          raise(ArgumentError, "O número de convênio informado é inválido, deveria ser de 4,6,7 ou 8 dígitos.")
        end
      end

      # Retorna digito verificador do nosso numero, calculado com modulo11 de 9 para 2, porem em caso de resultado ser 10, usa-se 'X'
      # Inclui ainda o numero do convenio no calculo
      def nosso_numero_dv
        "#{self.convenio}#{self.numero_documento_formatado}".modulo11_9to2_10_como_x
      end

      # Campo usado apenas na exibição no boleto
      #  Deverá ser sobreescrito para cada banco
      def nosso_numero_boleto
        "#{self.convenio}#{self.numero_documento_formatado}-#{self.nosso_numero_dv}"
      end

      # Campo usado apenas na exibição no boleto
      #  Deverá ser sobreescrito para cada banco
      def agencia_conta_boleto
        "#{self.agencia}-#{self.agencia_dv} / #{self.conta_corrente_formatado}-#{self.conta_corrente_dv}"
      end

      # Responsavel por montar uma String com 43 caracteres que será usado na criacao do codigo de barras
      def codigo_barras_segunda_parte
        # A montagem é feita baseada na quantidade de dígitos do convênio.
        case self.convenio.to_s.size
        when 8 # Nosso Numero de 17 dígitos com Convenio de 8 dígitos e numero_documento de 9 dígitos
          "000000#{self.convenio}#{self.numero_documento_formatado}#{self.carteira_formatado}"
        when 7 # Nosso Numero de 17 dígitos com Convenio de 7 dígitos e numero_documento de 10 dígitos
          "000000#{self.convenio}#{self.numero_documento_formatado}#{self.carteira_formatado}"
        when 6 # Convenio de 6 dígitos
          if self.codigo_servico == false
            # Nosso Numero de 11 dígitos com Convenio de 6 dígitos e numero_documento de 5 digitos
            "#{self.convenio}#{self.numero_documento_formatado}#{self.agencia}#{self.conta_corrente_formatado}#{self.carteira_formatado}"
          else
            # Nosso Numero de 17 dígitos com Convenio de 6 dígitos e sem numero_documento, carteira 16 e 18
            raise "Só é permitido emitir boletos com nosso número de 17 dígitos com carteiras 16 ou 18. Sua carteira atual é #{self.carteira_formatado}" unless (["16","18"].include?(self.carteira_formatado))
            "#{self.convenio}#{self.numero_documento_formatado}21"
          end
        when 4 # Nosso Numero de 7 dígitos com Convenio de 4 dígitos e sem numero_documento
          "#{self.convenio}#{self.numero_documento_formatado}#{self.agencia}#{self.conta_corrente_formatado}#{self.carteira_formatado}"
        else
          raise(ArgumentError, "O número de convênio informado é inválido, deveria ser de 4,6,7 ou 8 dígitos.")
        end
      end

    end
  end
end