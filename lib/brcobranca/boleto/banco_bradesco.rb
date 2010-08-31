# Banco BRADESCO
class BancoBradesco < Brcobranca::Boleto::Base
  # Responsável por definir dados iniciais quando se cria uma nova intancia da classe BancoBradesco
  def initialize(campos={})
    campos = {:carteira => "06", :banco => "237"}.merge!(campos)
    super
  end

  # Retorna Carteira utilizada formatada com 2 dígitos
  def carteira
    raise(ArgumentError, "A carteira informada não é válida. O BRADESCO utiliza carteira com apenas 2 dígitos.") if @carteira.to_s.size > 2
    @carteira.to_s.rjust(2,'0')
  end

  # Número seqüencial de 11 dígitos utilizado para identificar o boleto.
  def numero_documento
    @numero_documento.to_s.rjust(11,'0')
  end

  # Campo usado apenas na exibição no boleto
  def nosso_numero_boleto
    "#{self.carteira}/#{self.numero_documento}-#{self.nosso_numero_dv}"
  end

  # Campo usado apenas na exibição no boleto
  def agencia_conta_boleto
    "#{self.agencia}-#{self.agencia_dv} / #{self.conta_corrente}-#{self.conta_corrente_dv}"
  end

  # Responsável por montar uma String com 43 caracteres que será usado na criação do código de barras
  #   As posições do campo livre ficam a critério de cada Banco arrecadador, sendo que o
  #   padrão do Bradesco é:
  #   Posição Tamanho Conteúdo
  #   20 a 23 4 Agência Cedente (Sem o digito verificador, completar com zeros a esquerda quando  necessário)
  #   24 a 25 2 Carteira
  #   26 a 36 11 Número do Nosso Número(Sem o digito verificador)
  #   37 a 43 7 Conta do Cedente (Sem o digito verificador, completar com zeros a esquerda quando necessário)
  #   44 a 44 1 Zero

  def monta_codigo_43_digitos
    numero = "#{self.banco}#{self.moeda}#{self.fator_vencimento}#{self.valor_documento_formatado}#{self.agencia}#{self.carteira}#{self.numero_documento}#{self.conta_corrente}0"
    numero.size == 43 ? numero : raise(ArgumentError, "Não foi possível gerar um boleto válido.")
  end
end