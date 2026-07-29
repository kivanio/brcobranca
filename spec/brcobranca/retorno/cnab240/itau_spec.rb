# frozen_string_literal: true

require "spec_helper"

RSpec.describe Brcobranca::Retorno::Cnab240::Itau do
  before do
    @arquivo = File.join(
      File.dirname(__FILE__), "..", "..", "..", "arquivos", "CNAB240ITAU.RET"
    )
  end

  it "Transforma arquivo de retorno em 1 objeto de retorno" do
    pagamentos = described_class.load_lines(@arquivo)
    expect(pagamentos.size).to eq(1)
  end

  it "Segmento T: preenche os campos do titulo/pagador" do
    pagamento = described_class.load_lines(@arquivo).first
    expect(pagamento.codigo_ocorrencia).to eql("06")
    expect(pagamento.agencia_com_dv).to eql("1234")
    expect(pagamento.cedente_com_dv).to eql("1234506")
    expect(pagamento.carteira).to eql("175")
    expect(pagamento.nosso_numero).to eql("12345678")
    expect(pagamento.documento_numero).to eql("DOC000123")
    expect(pagamento.data_vencimento).to eql("15072026")
    expect(pagamento.valor_titulo).to eql("000000000012345")
    expect(pagamento.agencia_recebedora_com_dv).to eql("000000")
    expect(pagamento.valor_tarifa).to eql("000000000000500")
    expect(pagamento.sequencial).to eql("00001")
  end
end

RSpec.describe Brcobranca::Retorno::Cnab240::Itau do
  before do
    @arquivo = File.join(
      File.dirname(__FILE__), "..", "..", "..", "arquivos", "CNAB240ITAU.RET"
    )
  end

  it "Segmento U: preenche os campos da liquidacao" do
    pagamento = described_class.load_lines(@arquivo).first
    expect(pagamento.juros_mora).to eql("000000000000000")
    expect(pagamento.desconto_concedito).to eql("000000000000000")
    expect(pagamento.valor_abatimento).to eql("000000000000000")
    expect(pagamento.iof_desconto).to eql("000000000000000")
    expect(pagamento.valor_recebido).to eql("000000000012345")
    expect(pagamento.outros_recebimento).to eql("000000000012345")
    expect(pagamento.data_ocorrencia).to eql("29072026")
    expect(pagamento.data_credito).to eql("29072026")
  end
end

RSpec.describe Brcobranca::Retorno::Cnab240::Itau do
  describe ".validate_par_t_u!" do
    let(:linha_t) do
      described_class::Line.new.tap do |line|
        line.tipo_registro = "T"
        line.sequencial = "00001"
      end
    end
    let(:linha_u) do
      described_class::Line.new.tap { |line| line.tipo_registro = "U" }
    end

    it "nao levanta erro para um par T/U completo e na ordem correta" do
      expect { described_class.validate_par_t_u!([linha_t, linha_u]) }.
        not_to raise_error
    end

    it "levanta erro se faltar a linha U (arquivo truncado/corrompido)" do
      expect { described_class.validate_par_t_u!([linha_t]) }.
        to raise_error(ArgumentError, /00001/)
    end

    it "levanta erro se as linhas estiverem fora de ordem (U antes de T)" do
      expect { described_class.validate_par_t_u!([linha_u, linha_t]) }.
        to raise_error(ArgumentError)
    end
  end
end
