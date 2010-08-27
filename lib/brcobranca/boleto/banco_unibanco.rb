# Banco UNIBANCO
class BancoUnibanco < Brcobranca::Boleto::Base
  # Responsável por definir dados iniciais quando se cria uma nova intancia da classe BancoUnibanco
  #  Com Registro 4
  #  Sem Registro 5
  def initialize(campos={})
    padrao={:carteira => "5", :banco => "409"}
    campos = padrao.merge!(campos)
    super(campos)
  end

  def convenio
    @convenio.to_s.rjust(6,'0')
  end

  # Número seqüencial utilizado para identificar o boleto (Número de dígitos depende do tipo de carteira).
  def numero_documento
    case self.carteira.to_i
    when 5
      @numero_documento.to_s.rjust(14,'0')
    when 4
      @numero_documento.to_s.rjust(11,'0')
    end
  end

  def nosso_numero_dv
    raise(ArgumentError, "numero_documento não pode estar em branco.") unless self.numero_documento
    self.numero_documento.modulo11_2to9
  end

  # Campo usado apenas na exibição no boleto
  def nosso_numero_boleto
    "#{self.numero_documento}-#{self.nosso_numero_dv}"
  end

  # Campo usado apenas na exibição no boleto
  def agencia_conta_boleto
    "#{self.agencia} / #{self.conta_corrente}-#{self.conta_corrente_dv}"
  end

  # Responsável por montar uma String com 43 caracteres que será usado na criação do código de barras
  def monta_codigo_43_digitos
    fator = self.data_vencimento.fator_vencimento
    valor_documento = self.valor_documento.limpa_valor_moeda.to_s.rjust(10,'0')
    carteira = self.carteira.to_s.rjust(1,'0')

    case carteira.to_i
    when 5
      # Cobrança sem registro (CÓDIGO DE BARRAS)
      # Posição Tamanho Descrição
      # 1 a 3 3 número de identificação do Unibanco: 409 (número FIXO)
      # 4 1 código da moeda. Real (R$)=9 (número FIXO)
      # 5 1 dígito verificador do CÓDIGO DE BARRAS
      # 6 a 9 4 fator de vencimento
      # 10 a 19 10  valor do título com zeros à esquerda
      # 20  1 código para transação CVT: 5 (número FIXO)(5=7744-5)
      # 21 a 27 7 número do cliente no CÓDIGO DE BARRAS + dígito verificador
      # 28 a 29 2 vago. Usar 00 (número FIXO)
      # 30 a 43 14  Número de referência do cliente
      # 44  1 Dígito verificador

      codigo = "#{self.banco}#{self.moeda}#{fator}#{valor_documento}#{carteira}#{self.convenio}00#{self.numero_documento}#{self.nosso_numero_dv}"
      codigo.size == 43 ? codigo : raise(ArgumentError, "Não foi possível gerar um boleto válido.")
    when 4
      # Cobrança com registro (CÓDIGO DE BARRAS)
      # Posição  Tamanho Descrição
      # 1 a 3  3 Número de identificação do Unibanco: 409 (número FIXO)
      # 4  1 Código da moeda. Real (R$)=9 (número FIXO)
      # 5  1 dígito verificador do CÓDIGO DE BARRAS
      # 6 a 9  4 fator de vencimento em 4 algarismos, conforme tabela da página 14
      # 10 a 19  10  valor do título com zeros à esquerda
      # 20 a 21  2 Código para transação CVT: 04 (número FIXO) (04=5539-5)
      # 22 a 27  6 data de vencimento (AAMMDD)
      # 28 a 32  5 Código da agência + dígito verificador
      # 33 a 43  11  “Nosso Número” (NNNNNNNNNNN)
      # 44 1 Super dígito do “Nosso Número” (calculado com o MÓDULO 11 (de 2 a 9))

      data = self.data_vencimento.strftime('%y%m%d')
      codigo = "#{self.banco}#{self.moeda}#{fator}#{valor_documento}0#{carteira}#{data}#{self.agencia}#{self.agencia_dv}#{self.numero_documento}#{self.nosso_numero_dv}"
      codigo.size == 43 ? codigo : raise(ArgumentError, "Não foi possível gerar um boleto válido.")
    else
      raise RuntimeError, "Tipo de carteira não implementado"
    end
  end
end