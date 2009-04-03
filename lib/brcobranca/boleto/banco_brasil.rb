class BancoBrasil < Brcobranca::Boleto::Base

  # Responsavel por definir dados iniciais quando se cria uma nova intancia da classe BancoBrasil
  def initialize
    super
    self.carteira = "18"
    self.banco = "001"
    self.codigo_servico = false
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

  # Retorna digito verificador do nosso numero, calculado com modulo11 de 9 para 2, porem em caso de resultado ser 10, usa-se 'X'
  # Inclui ainda o numero do convenio no calculo
  def nosso_numero_dv
    "#{self.convenio}#{self.nosso_numero}".modulo11_9to2_10_como_x
  end

  # Responsavel por montar uma String com 43 caracteres que será usado na criacao do codigo de barras
  def monta_codigo_43_digitos
    banco = self.banco.zeros_esquerda(:tamanho => 3)
    valor_documento = self.valor_documento.limpa_valor_moeda.zeros_esquerda(:tamanho => 10)
    convenio = self.convenio.to_s
    fator = self.data_vencimento.fator_vencimento

    case convenio.size
    when 8 # Nosso Numero de 17 digitos com Convenio de 8 digitos e complemento de 9 digitos
      nosso_numero = self.nosso_numero.zeros_esquerda(:tamanho => 9)
      raise "Seu complemento está com #{nosso_numero.size} dígitos. Com convênio de 8 dígitos, somente permite-se até 9 dígitos no complemento do nosso numero." if nosso_numero.size > 9
      "#{banco}#{self.moeda}#{fator}#{valor_documento}000000#{convenio}#{nosso_numero}#{self.carteira}"
    when 7 # Nosso Numero de 17 digitos com Convenio de 7 digitos e complemento de 10 digitos
      nosso_numero = self.nosso_numero.zeros_esquerda(:tamanho => 10)
      raise "Seu complemento está com #{nosso_numero.size} dígitos. Com convênio de 7 dígitos, somente permite-se até 10 dígitos no complemento do nosso numero." if nosso_numero.size > 10
      "#{banco}#{self.moeda}#{fator}#{valor_documento}000000#{convenio}#{nosso_numero}#{self.carteira}"
    when 6 # Convenio de 6 digitos
      if self.codigo_servico == false
        # Nosso Numero de 11 digitos com Convenio de 6 digitos e complemento de 5 digitos
        nosso_numero = self.nosso_numero.zeros_esquerda(:tamanho => 5)
        raise "Seu complemento está com #{nosso_numero.size} dígitos. Com convênio de 6 dígitos, somente permite-se até 5 dígitos no complemento do nosso numero. Para emitir boletos com nosso numero de 17 dígitos, coloque o atributo codigo_servico=true" if nosso_numero.size > 5
        agencia = self.agencia.zeros_esquerda(:tamanho => 4)
        conta = self.conta_corrente.zeros_esquerda(:tamanho => 8)
        "#{banco}#{self.moeda}#{fator}#{valor_documento}#{convenio}#{nosso_numero}#{agencia}#{conta}#{self.carteira}"
      else
        # Nosso Numero de 17 digitos com Convenio de 6 digitos e sem complemento, carteira 16 e 18
        nosso_numero = self.nosso_numero.zeros_esquerda(:tamanho => 17)
        raise "Seu complemento está com #{nosso_numero.size} dígitos. Com convênio de 6 dígitos, somente permite-se até 17 dígitos no complemento do nosso numero." if (nosso_numero.size > 17)
        raise "Só é permitido emitir boletos com nosso número de 17 dígitos com carteiras 16 ou 18. Sua carteira atual é #{self.carteira}" unless (["16","18"].include?(self.carteira))
        # numero_dv = "#{banco}#{self.moeda}#{fator}#{valor_documento}#{convenio}#{nosso_numero}21"
        # dv_barra = numero_dv.modulo11_2to9
        "#{banco}#{self.moeda}#{fator}#{valor_documento}#{convenio}#{nosso_numero}21"
      end
    when 4 # Nosso Numero de 7 digitos com Convenio de 4 digitos e sem complemento
      nosso_numero = self.nosso_numero.zeros_esquerda(:tamanho => 7)
      raise "Seu complemento está com #{nosso_numero.size} dígitos. Com convênio de 4 dígitos, somente permite-se até 7 dígitos no complemento do nosso numero." if nosso_numero.size > 7
      agencia = self.agencia.zeros_esquerda(:tamanho => 4)
      conta = self.conta_corrente.zeros_esquerda(:tamanho => 8)
      "#{banco}#{self.moeda}#{fator}#{valor_documento}#{convenio}#{nosso_numero}#{agencia}#{conta}#{self.carteira}"
    else
      return nil
    end
  end

end