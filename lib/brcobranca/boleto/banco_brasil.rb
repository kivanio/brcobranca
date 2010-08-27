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
    banco = self.banco.to_s.rjust(3,'0')
    valor_documento = self.valor_documento.limpa_valor_moeda.to_s.rjust(10,'0')
    convenio = self.convenio.to_s
    fator = self.data_vencimento.fator_vencimento
    # A montagem é feita baseada na quantidade de dígitos do convênio.
    case convenio.size
    when 8 # Nosso Numero de 17 dígitos com Convenio de 8 dígitos e numero_documento de 9 dígitos
      raise ArgumentError, "Seu complemento está com #{numero_documento.size} dígitos. Com convênio de 8 dígitos, somente permite-se até 9 dígitos no numero_documento do nosso numero." if numero_documento.to_s.size > 9
      numero_documento = self.numero_documento.to_s.rjust(9,'0')
      numero = "#{banco}#{self.moeda}#{fator}#{valor_documento}000000#{convenio}#{numero_documento}#{self.carteira}"
    when 7 # Nosso Numero de 17 dígitos com Convenio de 7 dígitos e numero_documento de 10 dígitos
      raise ArgumentError, "Seu complemento está com #{numero_documento.size} dígitos. Com convênio de 7 dígitos, somente permite-se até 10 dígitos no numero_documento do nosso numero." if numero_documento.to_s.size > 10
      numero_documento = self.numero_documento.to_s.rjust(10,'0')
      numero = "#{banco}#{self.moeda}#{fator}#{valor_documento}000000#{convenio}#{numero_documento}#{self.carteira}"
    when 6 # Convenio de 6 dígitos
      if self.codigo_servico == false
        # Nosso Numero de 11 dígitos com Convenio de 6 dígitos e numero_documento de 5 digitos
        raise ArgumentError, "Seu numero_documento está com #{numero_documento.size} dígitos. Com convênio de 6 dígitos, somente permite-se até 5 dígitos no numero_documento do nosso numero. Para emitir boletos com nosso numero de 17 dígitos, coloque o atributo codigo_servico=true" if numero_documento.to_s.size > 5
        numero_documento = self.numero_documento.to_s.rjust(5,'0')
        agencia = self.agencia.to_s.rjust(4,'0')
        conta = self.conta_corrente.to_s.rjust(8,'0')
        numero = "#{banco}#{self.moeda}#{fator}#{valor_documento}#{convenio}#{numero_documento}#{agencia}#{conta}#{self.carteira}"
      else
        # Nosso Numero de 17 dígitos com Convenio de 6 dígitos e sem numero_documento, carteira 16 e 18
        raise ArgumentError, "Seu numero_documento está com #{numero_documento.size} dígitos. Com convênio de 6 dígitos, somente permite-se até 17 dígitos no numero_documento do nosso numero." if (numero_documento.to_s.size > 17)
        raise "Só é permitido emitir boletos com nosso número de 17 dígitos com carteiras 16 ou 18. Sua carteira atual é #{self.carteira}" unless (["16","18"].include?(self.carteira))
        numero_documento = self.numero_documento.to_s.rjust(17,'0')
        numero = "#{banco}#{self.moeda}#{fator}#{valor_documento}#{convenio}#{numero_documento}21"
      end
    when 4 # Nosso Numero de 7 dígitos com Convenio de 4 dígitos e sem numero_documento
      raise ArgumentError, "Seu numero_documento está com #{numero_documento.size} dígitos. Com convênio de 4 dígitos, somente permite-se até 7 dígitos no numero_documento do nosso numero." if numero_documento.to_s.size > 7
      numero_documento = self.numero_documento.to_s.rjust(7,'0')
      agencia = self.agencia.to_s.rjust(4,'0')
      conta = self.conta_corrente.to_s.rjust(8,'0')
      numero = "#{banco}#{self.moeda}#{fator}#{valor_documento}#{convenio}#{numero_documento}#{agencia}#{conta}#{self.carteira}"
    else
      numero = ""
    end

    numero.size == 43 ? numero : raise(ArgumentError, "Não foi possível gerar um boleto válido.")
  end

end