# Banco Itaú
class BancoItau < Brcobranca::Boleto::Base
  # Usado somente em carteiras especiais com registro para complementar o número do cocumento
  attr_accessor :seu_numero

  # Responsável por definir dados iniciais quando se cria uma nova intancia da classe BancoItau
  def initialize(campos={})
    padrao={:carteira => "175", :banco => "341"}
    campos = padrao.merge!(campos)
    super(campos)
  end

  def convenio
    @convenio.to_s.rjust(5,'0')
  end

  # Número seqüencial de 8 dígitos utilizado para identificar o boleto.
  def numero_documento
    raise ArgumentError, "numero_documento pode ser de no máximo 8 caracteres." if @numero_documento.to_s.size > 8
    @numero_documento.to_s.rjust(8,'0')
  end

  # Retorna dígito verificador do nosso número, calculado com modulo10.
  # Para a grande maioria das carteiras, são considerados para a obtenção do DAC/DV, os dados
  # "AGENCIA(sem DAC/DV)/CONTA(sem DAC/DV)/CARTEIRA/NOSSO NUMERO", calculado pelo criterio do Modulo 10.
  # A excecao, estão as carteiras 126, 131, 146, 150 e 168 cuja obtenção esta baseada apenas nos
  # dados "CARTEIRA/NOSSO NUMERO".
  def nosso_numero_dv
    if %w(126 131 146 150 168).include?(self.carteira)
      "#{self.carteira}#{self.numero_documento}".modulo10
    else
      "#{self.agencia}#{self.conta_corrente}#{self.carteira}#{self.numero_documento}".modulo10
    end
  end

  # Calcula o dígito verificador para conta corrente do Itau.
  # Retorna apenas o dígito verificador da conta ou nil caso seja impossível calcular.
  def agencia_conta_corrente_dv
    "#{self.agencia}#{self.conta_corrente}".modulo10
  end

  # Campo usado apenas na exibição no boleto
  #  Deverá ser sobreescrito para cada banco
  def nosso_numero_boleto
    "#{self.carteira}/#{self.numero_documento}-#{self.nosso_numero_dv}"
  end

  # Campo usado apenas na exibição no boleto
  #  Deverá ser sobreescrito para cada banco
  def agencia_conta_boleto
    "#{self.agencia} / #{self.conta_corrente}-#{self.agencia_conta_corrente_dv}"
  end

  # Responsável por montar uma String com 43 caracteres que será usado na criação do código de barras.
  def monta_codigo_43_digitos
    fator_vencimento = self.data_vencimento.fator_vencimento

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
      codigo = "#{self.banco}#{self.moeda}#{fator_vencimento}#{self.valor_documento_formatado}#{self.carteira}"
      codigo << "#{self.numero_documento}#{self.nosso_numero_dv}#{self.agencia}#{self.conta_corrente}#{self.agencia_conta_corrente_dv}000"
      codigo
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
      seu_numero = self.seu_numero.to_s.rjust(7,'0')
      dv = "#{self.carteira}#{numero_documento}#{seu_numero}#{self.convenio}".modulo10

      codigo = "#{self.banco}#{self.moeda}#{fator_vencimento}#{self.valor_documento_formatado}#{self.carteira}"
      codigo << "#{self.numero_documento}#{seu_numero}#{self.convenio}#{dv}0"
      codigo
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
      codigo = "#{self.banco}#{self.moeda}#{fator_vencimento}#{self.valor_documento_formatado}#{self.carteira}"
      codigo << "#{self.numero_documento}#{self.nosso_numero_dv}#{self.agencia}#{self.conta_corrente}#{self.agencia_conta_corrente_dv}000"
      codigo
      codigo.size == 43 ? codigo : raise(ArgumentError, "Não foi possível gerar um boleto válido.")
    end
  end
end
