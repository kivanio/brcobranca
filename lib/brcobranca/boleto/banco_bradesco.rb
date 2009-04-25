# Banco BRADESCO
class BancoBradesco < Brcobranca::Boleto::Base
  # Responsável por definir dados iniciais quando se cria uma nova intancia da classe BancoBradesco
  def initialize(campos={})
    padrao={:carteira => "06", :banco => "237"}
    campos = padrao.merge!(campos)
    super(campos)
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
    banco = self.banco.zeros_esquerda(:tamanho => 3)
    fator = self.data_vencimento.fator_vencimento
    valor_documento = self.valor_documento.limpa_valor_moeda.zeros_esquerda(:tamanho => 10)
    agencia = self.agencia.zeros_esquerda(:tamanho => 4)
    carteira = self.carteira.zeros_esquerda(:tamanho => 2)
    numero_documento = self.numero_documento.zeros_esquerda(:tamanho => 11)
    conta = self.conta_corrente.zeros_esquerda(:tamanho => 7)

    "#{banco}#{self.moeda}#{fator}#{valor_documento}#{agencia}#{carteira}#{numero_documento}#{conta}0"
  end
end