# Banco HSBC
class BancoHsbc < Brcobranca::Boleto::Base

  # Responsável por definir dados iniciais quando se cria uma nova intância da classe BancoBrasil
  def initialize(campos={})
    padrao={:carteira => "CNR", :banco => "399"}
    campos = padrao.merge!(campos)
    super(campos)
  end

  # Número sequencial utilizado para distinguir os boletos na agência
  def nosso_numero
    if self.data_vencimento
      self.codigo_servico = 4
      dia = self.data_vencimento.day.to_s.zeros_esquerda(:tamanho => 2)
      mes = self.data_vencimento.month.to_s.zeros_esquerda(:tamanho => 2)
      ano = self.data_vencimento.year.to_s[2..3]
      data = "#{dia}#{mes}#{ano}"

      numero_documento = "#{self.numero_documento.to_s}#{self.numero_documento.to_s.modulo11_9to2_10_como_zero}#{self.codigo_servico.to_s}"
      soma = numero_documento.to_i + self.conta_corrente.to_i + data.to_i
      numero = "#{numero_documento}#{soma.to_s.modulo11_9to2_10_como_zero}"
      numero
    else
      self.codigo_servico = 5
      numero_documento = "#{self.numero_documento.to_s}#{self.numero_documento.to_s.modulo11_9to2_10_como_zero}#{self.codigo_servico.to_s}"
      soma = numero_documento.to_i + self.conta_corrente.to_i
      numero = "#{numero_documento}#{soma.to_s.modulo11_9to2_10_como_zero}"
      numero
    end
  end

  # Responsável por montar uma String com 43 caracteres que será usado na criação do código de barras
  def monta_codigo_43_digitos
    banco = self.banco.zeros_esquerda(:tamanho => 3)
    valor_documento = self.valor_documento.limpa_valor_moeda.zeros_esquerda(:tamanho => 10)
    convenio = self.convenio.to_s
    conta = self.conta_corrente.zeros_esquerda(:tamanho => 7)

    # Montagem é baseada no tipo de carteira e na presença da data de vencimento
    if self.carteira == "CNR"
      if self.data_vencimento
        raise "numero_documento pode ser de no máximo 13 caracteres." if (self.numero_documento.to_s.size > 13)
        fator = self.data_vencimento.fator_vencimento
        dias_julianos = self.data_vencimento.to_juliano
        self.codigo_servico = 4
        numero_documento = self.numero_documento.zeros_esquerda(:tamanho => 13)       
        "#{banco}#{self.moeda}#{fator}#{valor_documento}#{conta}#{numero_documento}#{dias_julianos}2"
      else
        # TODO
        nil
      end
    else
      raise "numero_documento pode ser de no máximo 6 caracteres." if (self.numero_documento.to_s.size > 6)
      numero_documento = self.numero_documento.zeros_esquerda(:tamanho => 6)
      nosso_numero = self.nosso_numero.zeros_esquerda(:tamanho => 9)
      self.codigo_servico = 5
      # TODO
      nil
    end
  end

end