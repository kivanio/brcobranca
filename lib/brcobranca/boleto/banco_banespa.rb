# Banco BANESPA
class BancoBanespa < Brcobranca::Boleto::Base

  def initialize(campos={})
    padrao = {:carteira => "COB", :banco => "033"}
    campos = padrao.merge!(campos)
    super(campos)
  end

  # Número sequencial utilizado para distinguir os boletos na agência
  def nosso_numero
    "#{self.agencia.zeros_esquerda(:tamanho => 3)}#{self.numero_documento.zeros_esquerda(:tamanho => 7)}"
  end

  # Retorna dígito verificador do nosso número calculado como contas na documentação
  def nosso_numero_dv
    self.nosso_numero.zeros_esquerda(:tamanho => 10).modulo_10_banespa
  end

  # Retorna nosso numero pronto para exibir no boleto
  def nosso_numero_boleto
    "#{self.nosso_numero[0..2]} #{self.nosso_numero[3..9]} #{self.nosso_numero_dv}"
  end

  def agencia_conta_boleto
    convenio = self.convenio.zeros_esquerda(:tamanho => 11)
    "#{convenio[0..2]} #{convenio[3..4]} #{convenio[5..9]} #{convenio[10..10]}"
  end

  # Responsável por montar uma String com 43 caracteres que será usado na criação do código de barras.
  def monta_codigo_43_digitos
    banco = self.banco.zeros_esquerda(:tamanho => 3)
    fator = self.data_vencimento.fator_vencimento.zeros_esquerda(:tamanho => 4)
    valor_documento = self.valor_documento.limpa_valor_moeda.zeros_esquerda(:tamanho => 10)
    numero = "#{banco}#{self.moeda}#{fator}#{valor_documento}#{self.campo_livre_com_dv1_e_dv2}"
    numero.size == 43 ? numero : nil
  end

  # CAMPO LIVRE
  #    Código do cedente                                                                            PIC  9  (011)
  #    Nosso número                                                                                 PIC  9  (007)
  #    Filler                                                                                       PIC  9  (002)   = 00
  #    Código do banco cedente                                                                      PIC  9  (003)   = 033
  #    Dígito verificador 1                                                                         PIC  9  (001)
  #    Dígito verificador 2                                                                         PIC  9  (001)
  def campo_livre
    "#{self.convenio.zeros_esquerda(:tamanho => 11)}#{self.numero_documento.zeros_esquerda(:tamanho => 7)}00#{self.banco.zeros_esquerda(:tamanho => 3)}"
  end

  #campo livre com os digitos verificadores como conta na documentação do banco
  def campo_livre_com_dv1_e_dv2
    dv1 = self.campo_livre.modulo10 #dv 1 inicial
    dv2 = nil
    multiplicadores = [2,3,4,5,6,7]
    begin
      recalcular_dv2 = false
      valor_inicial = "#{self.campo_livre}#{dv1}"
      total = 0
      multiplicador_posicao = 0

      valor_inicial.split(//).reverse!.each do |caracter|
        multiplicador_posicao = 0 if (multiplicador_posicao == 6)
        total += (caracter.to_i * multiplicadores[multiplicador_posicao])
        multiplicador_posicao += 1
      end

      case total % 11
      when 0 then
        dv2 = 0
      when 1 then
        if dv1 == 9
          dv1 = 0
        else
          dv1 += 1
        end
        recalcular_dv2 = true
      else
        dv2 = 11 - (total % 11)
      end
    end while(recalcular_dv2)

    return "#{self.campo_livre}#{dv1}#{dv2}"
  end

end