# Banco Caixa
class BancoCaixa < Brcobranca::Boleto::Base
  MODALIDADE_COBRANCA = {
    :registrada => '1',
    :sem_registro => '2'
  }

  EMISSAO_BOLETO = {
    :cedente => '4'
  }

  # Validações
  # validates_length_of :carteira, :is => 2, :message => 'deve possuir 2 dígitos.'
  # validates_length_of :convenio, :is => 6, :message => 'deve possuir 6 dígitos.'
  # validates_length_of :numero_documento, :is => 15, :message => 'deve possuir 15 dígitos.'

  # Nova instância da CaixaEconomica
  # @param (see Brcobranca::Boleto::Base#initialize)
  def initialize campos = {} 
    campos = {
      :carteira => "#{MODALIDADE_COBRANCA[:sem_registro]}#{EMISSAO_BOLETO[:cedente]}" 
    }.merge!(campos)

    campos.merge!(:convenio => campos[:convenio].rjust(6, '0')) if campos[:convenio]
    campos.merge!(:numero_documento => campos[:numero_documento].rjust(15, '0')) if campos[:numero_documento]

    super(campos)
  end

  # Código do banco emissor
  # @return [String]
  def banco; '104' end

  # Nosso número, 17 dígitos
  #  1 à 2: carteira
  #  3 à 17: campo_livre
  # @return [String]
  def nosso_numero_boleto
    "#{carteira}#{numero_documento}"      
  end

  # Número da agência/codigo_cedente do cliente para exibir no boleto.
  # @return [String]
  # @example
  #  boleto.agencia_conta_boleto #=> "2391/44335511-5"
  def agencia_conta_boleto            
    "#{agencia}/#{conta_corrente}-#{conta_corrente_dv}"
  end

  # Dígito verificador do convênio ou código do cedente
  # @return [String]
  def convenio_dv
    raise Brcobranca::BoletoInvalido.new unless convenio
    "#{convenio.modulo11_2to9}"
  end

  def fator_vencimento
    data_vencimento.fator_vencimento.to_s.rjust(4,'0')
  end

  # Valor total do documento
  # @return [String] 10 caracteres numéricos.
  def valor_documento_formatado
    valor_documento.limpa_valor_moeda.to_s.rjust(10,'0')
  end

  def codigo_barras
    codigo = super()
    raise Brcobranca::BoletoInvalido.new unless codigo 
    codigo
  end

  def monta_codigo_43_digitos
    "#{codigo_barras_primeira_parte}#{codigo_barras_segunda_parte}"
  end

  def codigo_barras_primeira_parte
    "#{banco}" <<
    "#{moeda}" <<
    "#{fator_vencimento}" <<
    "#{valor_documento_formatado}"
  end

  # Monta a segunda parte do código de barras.
  #  1 à 6: código do cedente, também conhecido como convênio
  #  7: dígito verificador do código do cedente
  #  8 à 10: dígito 3 à 5 do nosso número
  #  11: dígito 1 do nosso número (modalidade da cobrança)
  #  12 à 14: dígito 6 à 8 do nosso número
  #  15: dígito 2 do nosso número (emissão do boleto)
  #  16 à 24: dígito 9 à 17 do nosso número
  #  25: dígito verificador do campo livre
  # @return [String]
  def codigo_barras_segunda_parte
    campo_livre = "#{convenio}" << 
    "#{convenio_dv}" <<
    "#{nosso_numero_boleto[2..4]}" <<
    "#{nosso_numero_boleto[0..0]}" <<
    "#{nosso_numero_boleto[5..7]}" <<
    "#{nosso_numero_boleto[1..1]}" <<
    "#{nosso_numero_boleto[8..16]}"
    
    "#{campo_livre}#{campo_livre.modulo11_2to9}"
  end


end
