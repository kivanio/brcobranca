# Banco REAL
class BancoReal < Brcobranca::Boleto::Base
  # Responsável por definir dados iniciais quando se cria uma nova intancia da classe BancoReal
  def initialize(campos={})
    padrao={:carteira => "57", :banco => "356"}
    campos = padrao.merge!(campos)
    super(campos)
  end

  # Campo usado apenas na exibição no boleto
  #  Deverá ser sobreescrito para cada banco
  def nosso_numero_boleto
   "#{self.numero_documento}-#{self.nosso_numero_dv}"
  end

  # Campo usado apenas na exibição no boleto
  #  Deverá ser sobreescrito para cada banco
  def agencia_conta_boleto
   "#{self.agencia}-#{self.agencia_dv} / #{self.conta_corrente}-#{self.conta_corrente_dv}"
  end

  # CALCULO DO DIGITO:
  #  APLICA-SE OS PESOS 2,1,2,1,.... AOS ALGARISMOS DO NUMERO COMPOSTO POR:
  #  NUMERO DO BANCO : COM 7 DIGITOS P/ COBRANCA REGISTRADA
  #                     ATE 15 DIGITOS P/ COBRANCA SEM REGISTRO
  #  CODIGO DA AGENCIA: 4 DIGITOS
  #  NUMERO DA CONTA : 7 DIGITOS
  def agencia_conta_corrente_nosso_numero_dv
    #conta é 7 digitos
    conta = self.conta_corrente.to_s.rjust(7,'0')

    case self.carteira.to_i
    when 57
      #nosso número com maximo de 15 digitos
      numero_documento = self.numero_documento.to_s.rjust(15,'0')
      "#{numero_documento}#{self.agencia}#{conta}".modulo10
    else
      #nosso número com maximo de 7 digitos
      numero_documento = self.numero_documento.to_s.rjust(7,'0')
      "#{numero_documento}#{self.agencia}#{conta}".modulo10
    end
  end

  # Responsável por montar uma String com 43 caracteres que será usado na criação do código de barras
  def monta_codigo_43_digitos
    valor_documento = self.valor_documento.limpa_valor_moeda.to_s.rjust(10,'0')
    conta = self.conta_corrente.to_s.rjust(7,'0')
    fator = self.data_vencimento.fator_vencimento
    # Montagem é baseada no tipo de carteira, com registro e sem registro
    case self.carteira.to_i
      # Carteira sem registro
    when 57
      numero_documento = self.numero_documento.to_s.rjust(13,'0')
      codigo = "#{self.banco}#{self.moeda}#{fator}#{valor_documento}#{self.agencia}#{conta}#{self.agencia_conta_corrente_nosso_numero_dv}#{numero_documento}"
      codigo.size == 43 ? codigo : nil
    else
      # TODO verificar com o banco, pois não consta na documentação
      numero_documento = self.numero_documento.to_s.rjust(7,'0')
      codigo = "#{self.banco}#{self.moeda}#{fator}#{valor_documento}000000#{self.agencia}#{conta}#{self.agencia_conta_corrente_nosso_numero_dv}#{numero_documento}"
      codigo.size == 43 ? codigo : nil
    end
  end
end