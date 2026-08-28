# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Brcobranca::Retorno::Cnab240::Caixa do
  # A Caixa reaproveita o layout generico do CNAB 240 e sobrescreve apenas
  # alguns campos. Estes exemplos garantem que o reaproveitamento continua
  # valendo e, principalmente, que ele nao vaza para o layout generico.
  let(:layout_caixa) do
    described_class::Line.parse_values.each_with_object({}) { |(campo, range, _), acc| acc[campo] = range }
  end

  let(:layout_generico) do
    Brcobranca::Retorno::RetornoCnab240::Line.parse_values
                                             .each_with_object({}) { |(campo, range, _), acc| acc[campo] = range }
  end

  it 'herda os campos do layout generico do CNAB 240' do
    expect(layout_caixa.keys).to include(:data_vencimento, :valor_titulo, :banco_recebedor, :valor_tarifa)
  end

  it 'sobrescreve o nosso numero com as posicoes da Caixa' do
    expect(layout_caixa[:nosso_numero]).to eq(39..55)
  end

  it 'sobrescreve a agencia recebedora com as posicoes da Caixa' do
    expect(layout_caixa[:agencia_recebedora_com_dv]).to eq(99..103)
  end

  it 'nao altera o layout generico do CNAB 240' do
    expect(layout_generico[:nosso_numero]).to eq(46..56)
    expect(layout_generico[:agencia_recebedora_com_dv]).to eq(99..104)
  end

  context 'quando le um arquivo' do
    let(:arquivo) do
      file = Tempfile.new(['retorno_caixa', '.RET'])
      file.write("#{registro('T')}\r\n#{registro('U')}\r\n")
      file.rewind
      file
    end

    after do
      arquivo.close
      arquivo.unlink
    end

    # Registro de 240 posicoes reconhecido pelo filtro do CNAB 240:
    # posicao 8 = '3' (detalhe) e posicao 14 = segmento T ou U.
    def registro(segmento)
      linha = '0' * 240
      linha[7] = '3'
      linha[13] = segmento
      linha[39..55] = '12345678901234567' # nosso numero na posicao da Caixa
      linha[99..104] = '987654'           # agencia recebedora + 1 digito
      linha
    end

    it 'usa o layout da Caixa, e nao o generico' do
      retornos = described_class.load_lines(arquivo.path)

      expect(retornos.size).to eq(1)
      expect(retornos.first.nosso_numero).to eq('12345678901234567')
      expect(retornos.first.agencia_recebedora_com_dv).to eq('98765')
    end
  end
end
