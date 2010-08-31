# Banco REAL
class BancoReal < Brcobranca::Boleto::Base
  # Responsável por definir dados iniciais quando se cria uma nova intancia da classe BancoReal
  def initialize(campos={})
    campos = {:carteira => "57"}.merge!(campos)
    super
  end

  # Codigo do banco emissor (3 dígitos sempre)
  def banco
    "356"
  end

  # Número seqüencial utilizado para identificar o boleto (Número de dígitos depende do tipo de carteira).
  #  NUMERO DO BANCO : COM 7 DIGITOS P/ COBRANCA REGISTRADA
  #                     ATE 15 DIGITOS P/ COBRANCA SEM REGISTRO
  def numero_documento_formatado
    case self.carteira.to_i
    when 57
      #nosso número com maximo de 15 digitos
      @numero_documento.to_s.rjust(13,'0')
    else
      #nosso número com maximo de 7 digitos
      @numero_documento.to_s.rjust(7,'0')
    end
  end

  # Campo usado apenas na exibição no boleto
  #  Deverá ser sobreescrito para cada banco
  def nosso_numero_boleto
    "#{self.numero_documento_formatado}-#{self.nosso_numero_dv}"
  end

  # Campo usado apenas na exibição no boleto
  #  Deverá ser sobreescrito para cada banco
  def agencia_conta_boleto
    "#{self.agencia_formatado}-#{self.agencia_dv} / #{self.conta_corrente_formatado}-#{self.conta_corrente_dv}"
  end

  # CALCULO DO DIGITO:
  #  APLICA-SE OS PESOS 2,1,2,1,.... AOS ALGARISMOS DO NUMERO COMPOSTO POR:
  #  NUMERO DO BANCO : COM 7 DIGITOS P/ COBRANCA REGISTRADA
  #                     ATE 15 DIGITOS P/ COBRANCA SEM REGISTRO
  #  CODIGO DA AGENCIA: 4 DIGITOS
  #  NUMERO DA CONTA : 7 DIGITOS
  def agencia_conta_corrente_nosso_numero_dv
    "#{self.numero_documento_formatado}#{self.agencia_formatado}#{self.conta_corrente_formatado}".modulo10
  end

  # Responsável por montar uma String com 43 caracteres que será usado na criação do código de barras
  def monta_codigo_43_digitos
    if self.valid?
      # Montagem é baseada no tipo de carteira, com registro e sem registro
      case self.carteira.to_i
        # Carteira sem registro
      when 57
        codigo = "#{self.banco}#{self.moeda}#{self.fator_vencimento}#{self.valor_documento_formatado}#{self.agencia_formatado}#{self.conta_corrente_formatado}#{self.agencia_conta_corrente_nosso_numero_dv}#{self.numero_documento_formatado}"
        codigo.size == 43 ? codigo : raise(ArgumentError, "Não foi possível gerar um boleto válido.")
      else
        # TODO verificar com o banco, pois não consta na documentação
        codigo = "#{self.banco}#{self.moeda}#{self.fator_vencimento}#{self.valor_documento_formatado}000000#{self.agencia_formatado}#{self.conta_corrente_formatado}#{self.agencia_conta_corrente_nosso_numero_dv}#{self.numero_documento_formatado}"
        codigo.size == 43 ? codigo : raise(ArgumentError, "Não foi possível gerar um boleto válido.")
      end
    else
      raise ArgumentError, self.errors.full_messages
    end
  end
end