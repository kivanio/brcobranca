# Banco HSBC
class BancoHsbc < Brcobranca::Boleto::Base

  # Responsável por definir dados iniciais quando se cria uma nova intância da classe BancoBrasil
  def initialize(campos={})
    campos = {:carteira => "CNR", :banco => "399"}.merge!(campos)
    super
  end

  # Número seqüencial de 13 dígitos utilizado para identificar o boleto.
  def numero_documento
    raise ArgumentError, "numero_documento pode ser de no máximo 13 caracteres." if @numero_documento.to_s.size > 13
    @numero_documento.to_s.rjust(13,'0')
  end

  # Número sequencial utilizado para distinguir os boletos na agência
  def nosso_numero
    if self.data_vencimento.kind_of?(Date)
      self.codigo_servico = "4"
      dia = self.data_vencimento.day.to_s.rjust(2,'0')
      mes = self.data_vencimento.month.to_s.rjust(2,'0')
      ano = self.data_vencimento.year.to_s[2..3]
      data = "#{dia}#{mes}#{ano}"

      parte_1 = "#{self.numero_documento}#{self.numero_documento.modulo11_9to2_10_como_zero}#{self.codigo_servico}"
      soma = parte_1.to_i + self.conta_corrente.to_i + data.to_i
      numero = "#{parte_1}#{soma.to_s.modulo11_9to2_10_como_zero}"
      numero
    else
      self.codigo_servico = "5"
      parte_1 = "#{self.numero_documento}#{self.numero_documento.modulo11_9to2_10_como_zero}#{self.codigo_servico}"
      soma = parte_1.to_i + self.conta_corrente.to_i
      numero = "#{parte_1}#{soma.to_s.modulo11_9to2_10_como_zero}"
      numero
    end
  end

  # Campo usado apenas na exibição no boleto
  #  Deverá ser sobreescrito para cada banco
  def nosso_numero_boleto
    self.nosso_numero
  end

  # Campo usado apenas na exibição no boleto
  #  Deverá ser sobreescrito para cada banco
  def agencia_conta_boleto
    self.conta_corrente
  end

  # Responsável por montar uma String com 43 caracteres que será usado na criação do código de barras
  def monta_codigo_43_digitos
    # Montagem é baseada no tipo de carteira e na presença da data de vencimento
    if self.carteira == "CNR"
      dias_julianos = self.data_vencimento.to_juliano
      numero = "#{self.banco}#{self.moeda}#{self.fator_vencimento}#{self.valor_documento_formatado}#{self.conta_corrente}#{self.numero_documento}#{dias_julianos}2"
      numero.size == 43 ? numero : raise(ArgumentError, "Não foi possível gerar um boleto válido.")
    else
      raise RuntimeError, "Tipo de carteira não implementado"
    end
  end

end