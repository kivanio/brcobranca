# Banco Itaú
class BancoItau < Brcobranca::Boleto::Base
  # Usado somente em carteiras especiais com registro para complementar o número do cocumento
  attr_writer :seu_numero

  # Responsável por definir dados iniciais quando se cria uma nova intancia da classe BancoItau
  def initialize(campos={})
    campos = {:carteira => "175"}.merge!(campos)
    super
  end

  # Codigo do banco emissor (3 dígitos sempre)
  def banco
    "341"
  end

  # Número do convênio/contrato do cliente junto ao banco emissor formatado com 5 dígitos
  def convenio_formatado
    @convenio.to_s.rjust(5,'0')
  end

  # Retorna número da conta corrente formatado
  def conta_corrente_formatado
    @conta_corrente.to_s.rjust(5,'0')
  end

  # Número seqüencial de 8 dígitos utilizado para identificar o boleto.
  def numero_documento_formatado
    raise ArgumentError, "numero_documento pode ser de no máximo 8 caracteres." if @numero_documento.to_s.size > 8
    @numero_documento.to_s.rjust(8,'0')
  end

  # Retorna seu número formatado com 7 dígitos
  def seu_numero_formatado
    @seu_numero.to_s.rjust(7,'0')
  end

  # Retorna dígito verificador do nosso número, calculado com modulo10.
  # Para a grande maioria das carteiras, são considerados para a obtenção do DAC/DV, os dados
  # "AGENCIA(sem DAC/DV)/CONTA(sem DAC/DV)/CARTEIRA/NOSSO NUMERO", calculado pelo criterio do Modulo 10.
  # A excecao, estão as carteiras 126, 131, 146, 150 e 168 cuja obtenção esta baseada apenas nos
  # dados "CARTEIRA/NOSSO NUMERO".
  def nosso_numero_dv
    if %w(126 131 146 150 168).include?(self.carteira)
      "#{self.carteira}#{self.numero_documento_formatado}".modulo10
    else
      "#{self.agencia_formatado}#{self.conta_corrente_formatado}#{self.carteira}#{self.numero_documento_formatado}".modulo10
    end
  end

  # Calcula o dígito verificador para conta corrente do Itau.
  # Retorna apenas o dígito verificador da conta ou nil caso seja impossível calcular.
  def agencia_conta_corrente_dv
    "#{self.agencia_formatado}#{self.conta_corrente_formatado}".modulo10
  end

  # Campo usado apenas na exibição no boleto
  #  Deverá ser sobreescrito para cada banco
  def nosso_numero_boleto
    "#{self.carteira}/#{self.numero_documento_formatado}-#{self.nosso_numero_dv}"
  end

  # Campo usado apenas na exibição no boleto
  #  Deverá ser sobreescrito para cada banco
  def agencia_conta_boleto
    "#{self.agencia_formatado} / #{self.conta_corrente_formatado}-#{self.agencia_conta_corrente_dv}"
  end

  # Responsável por montar uma String com 43 caracteres que será usado na criação do código de barras.
  def monta_codigo_43_digitos
    if self.valid?
      # Monta a String baseado no tipo de carteira
      case self.carteira.to_i
      when 126, 131, 146, 150, 168
        # CARTEIRAS 126 131 146 150 168
        # 01 a 03 03 9(03) Código do Banco na Câmara de Compensação = '341'
        # 04 a 04 01 9(01) Código da Moeda = '9'
        # 05 a 05 01 9(01) DAC código de Barras MOD 11-2a9
        # 06 a 09 04 9(04) Fator de Vencimento
        # 10 a 19 10 9(08)V(2) Valor
        # 20 a 22 03 9(03) Carteira
        # 23 a 30 08 9(08) Nosso Número
        # 31 a 31 01 9(01) DAC [Carteira/Nosso Número] MOD 10
        # 32 a 35 04 9(04) N.º da Agência cedente
        # 36 a 40 05 9(05) N.º da Conta Corrente
        # 41 a 41 01 9(01) DAC [Agência/Conta Corrente] MOD 10
        # 42 a 44 03 9(03) Zeros
        codigo = "#{self.banco}#{self.moeda}#{self.fator_vencimento}#{self.valor_documento_formatado}#{self.carteira}"
        codigo << "#{self.numero_documento_formatado}#{self.nosso_numero_dv}#{self.agencia_formatado}#{self.conta_corrente_formatado}#{self.agencia_conta_corrente_dv}000"
        codigo.size == 43 ? codigo : raise(ArgumentError, "Não foi possível gerar um boleto válido.")
      when 198, 106, 107, 122, 142, 143, 195, 196
        # CARTEIRAS 198, 106, 107,122, 142, 143, 195 e 196
        # 01 a 03 03 9(3) Código do Banco na Câmara de Compensação = ‘341’
        # 04 a 04 01 9(1) Código da Moeda = '9'
        # 05 a 05 01 9(1) DAC do Código de Barras MOD 11-2a9
        # 06 a 09 04 9(04) Fator de Vencimento
        # 10 a 19 10 9(08) V(2) Valor
        # 20 a 22 03 9(3) Carteira
        # 23 a 30 08 9(8) Nosso Número
        # 31 a 37 07 9(7) Seu Número (Número do Documento)
        # 38 a 42 05 9(5) Código do Cliente (fornecido pelo Banco)
        # 43 a 43 01 9(1) DAC dos campos acima (posições 20 a 42) MOD 10
        # 44 a 44 01 9(1) Zero
        dv = "#{self.carteira}#{numero_documento_formatado}#{self.seu_numero_formatado}#{self.convenio_formatado}".modulo10
        codigo = "#{self.banco}#{self.moeda}#{self.fator_vencimento}#{self.valor_documento_formatado}#{self.carteira}"
        codigo << "#{self.numero_documento_formatado}#{self.seu_numero_formatado}#{self.convenio_formatado}#{dv}0"
        codigo.size == 43 ? codigo : raise(ArgumentError, "Não foi possível gerar um boleto válido.")
      else
        # DEMAIS CARTEIRAS
        # 01 a 03 03 9(03) Código do Banco na Câmara de Compensação = '341'
        # 04 a 04 01 9(01) Código da Moeda = '9'
        # 05 a 05 01 9(01) DAC código de Barras MOD 11-2a9
        # 06 a 09 04 9(04) Fator de Vencimento
        # 10 a 19 10 9(08)V(2) Valor
        # 20 a 22 03 9(03) Carteira
        # 23 a 30 08 9(08) Nosso Número
        # 31 a 31 01 9(01) DAC [Agência /Conta/Carteira/Nosso Número] MOD 10
        # 32 a 35 04 9(04) N.º da Agência cedente
        # 36 a 40 05 9(05) N.º da Conta Corrente
        # 41 a 41 01 9(01) DAC [Agência/Conta Corrente] MOD 10
        # 42 a 44 03 9(03) Zeros
        codigo = "#{self.banco}#{self.moeda}#{self.fator_vencimento}#{self.valor_documento_formatado}#{self.carteira}"
        codigo << "#{self.numero_documento_formatado}#{self.nosso_numero_dv}#{self.agencia_formatado}#{self.conta_corrente_formatado}#{self.agencia_conta_corrente_dv}000"
        codigo.size == 43 ? codigo : raise(ArgumentError, "Não foi possível gerar um boleto válido.")
      end
    else
      raise ArgumentError, self.errors.full_messages
    end
  end

end
