# Banco do Brasil
class BancoBrasil < Brcobranca::Boleto::Base

  # Responsável por definir dados iniciais quando se cria uma nova intância da classe BancoBrasil
  def initialize(campos={})
    padrao={:carteira => "18", :banco => "001", :codigo_servico => false}
    campos = padrao.merge!(campos)
    super(campos)
  end

  # Retorna digito verificador do banco, calculado com modulo11 de 9 para 2, porem em caso de resultado ser 10, usa-se 'X'
  def banco_dv
    self.banco.modulo11_9to2_10_como_x
  end

  # Retorna digito verificador da agencia, calculado com modulo11 de 9 para 2, porem em caso de resultado ser 10, usa-se 'X'
  def agencia_dv
    self.agencia.modulo11_9to2_10_como_x
  end

  # Retorna digito verificador da conta corrente, calculado com modulo11 de 9 para 2, porem em caso de resultado ser 10, usa-se 'X'
  def conta_corrente_dv
    self.conta_corrente.modulo11_9to2_10_como_x
  end

  # Número seqüencial utilizado para identificar o boleto (Número de dígitos depende do tipo de convênio).
  def numero_documento
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
    "#{self.convenio}#{self.numero_documento}".modulo11_9to2_10_como_x
  end

  # Campo usado apenas na exibição no boleto
  #  Deverá ser sobreescrito para cada banco
  def nosso_numero_boleto
    "#{self.convenio}#{self.numero_documento}-#{self.nosso_numero_dv}"
  end

  # Campo usado apenas na exibição no boleto
  #  Deverá ser sobreescrito para cada banco
  def agencia_conta_boleto
    "#{self.agencia}-#{self.agencia_dv} / #{self.conta_corrente}-#{self.conta_corrente_dv}"
  end

  # Responsavel por montar uma String com 43 caracteres que será usado na criacao do codigo de barras
  def monta_codigo_43_digitos
    # A montagem é feita baseada na quantidade de dígitos do convênio.
    case self.convenio.to_s.size
    when 8 # Nosso Numero de 17 dígitos com Convenio de 8 dígitos e numero_documento de 9 dígitos
      numero = "#{self.banco}#{self.moeda}#{self.fator_vencimento}#{self.valor_documento_formatado}000000#{self.convenio}#{self.numero_documento}#{self.carteira}"
    when 7 # Nosso Numero de 17 dígitos com Convenio de 7 dígitos e numero_documento de 10 dígitos
      numero = "#{self.banco}#{self.moeda}#{self.fator_vencimento}#{self.valor_documento_formatado}000000#{self.convenio}#{self.numero_documento}#{self.carteira}"
    when 6 # Convenio de 6 dígitos
      if self.codigo_servico == false
        # Nosso Numero de 11 dígitos com Convenio de 6 dígitos e numero_documento de 5 digitos
        conta = self.conta_corrente.to_s.rjust(8,'0')
        numero = "#{self.banco}#{self.moeda}#{self.fator_vencimento}#{self.valor_documento_formatado}#{self.convenio}#{self.numero_documento}#{self.agencia}#{conta}#{self.carteira}"
      else
        # Nosso Numero de 17 dígitos com Convenio de 6 dígitos e sem numero_documento, carteira 16 e 18
        raise "Só é permitido emitir boletos com nosso número de 17 dígitos com carteiras 16 ou 18. Sua carteira atual é #{self.carteira}" unless (["16","18"].include?(self.carteira))
        numero = "#{self.banco}#{self.moeda}#{self.fator_vencimento}#{self.valor_documento_formatado}#{self.convenio}#{self.numero_documento}21"
      end
    when 4 # Nosso Numero de 7 dígitos com Convenio de 4 dígitos e sem numero_documento
      conta = self.conta_corrente.to_s.rjust(8,'0')
      numero = "#{self.banco}#{self.moeda}#{self.fator_vencimento}#{self.valor_documento_formatado}#{self.convenio}#{self.numero_documento}#{self.agencia}#{conta}#{self.carteira}"
    else
      raise(ArgumentError, "O número de convênio informado é inválido, deveria ser de 4,6,7 ou 8 dígitos.")
    end

    numero.size == 43 ? numero : raise(ArgumentError, "Não foi possível gerar um boleto válido.")
  end

end