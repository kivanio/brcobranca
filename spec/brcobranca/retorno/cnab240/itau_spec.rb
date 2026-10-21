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


RSpec.describe Brcobranca::Retorno::Cnab240::Itau do
  # O Layout Padrao Febraban 240 posicoes V11.0 (11/09/2026) traz os dados do
  # Split Payment (IBS/CBS) no Segmento X-03, acompanhado do Segmento X-04 com
  # os valores da liquidacao do boleto.
  describe "Segmento X-03 e X-04 (Split Payment IBS/CBS)" do
    let(:arquivo) do
      File.join(
        File.dirname(__FILE__), "..", "..", "..", "arquivos",
        "CNAB240ITAU-SPLIT-PAYMENT.RET"
      )
    end
    let(:retornos) { described_class.load_lines(arquivo) }

    it "le os dois titulos do arquivo" do
      expect(retornos.size).to eq(2)
    end

    it "mantem a leitura do par T/U do titulo que tem os registros do Split Payment" do
      com_split = retornos.first

      expect(com_split.nosso_numero).to eql("12345678")
      expect(com_split.codigo_ocorrencia).to eql("06")
      expect(com_split.valor_recebido).to eql("000000000012345")
      expect(com_split.data_credito).to eql("29072026")
    end

    it "le os campos do Segmento X-03 do titulo" do
      com_split = retornos.first

      expect(com_split.identificacao_registro_opcional).to eql("03")
      expect(com_split.documento_fiscal).
        to eql("35260647906085000135550010000012341000012345")
      expect(com_split.valor_cbs_informado).to eql("000000000000180")
      expect(com_split.valor_ibs_informado).to eql("000000000000020")
      expect(com_split.valor_cbs_corrigido).to eql("000000000000180")
      expect(com_split.valor_ibs_corrigido).to eql("000000000000020")
      expect(com_split.valor_cbs_em_aberto).to eql("000000000000000")
      expect(com_split.valor_ibs_em_aberto).to eql("000000000000000")
      expect(com_split.valor_cbs_segregado).to eql("000000000000180")
      expect(com_split.valor_ibs_segregado).to eql("000000000000020")
      expect(com_split.id_split).to eql("E2E12345678901234567890123456789012")
      expect(com_split.tipo_id_split).to eql("E2E")
    end

    it "le os campos do Segmento X-04 (valores da liquidacao) do titulo" do
      com_split = retornos.first

      expect(com_split.valor_pago_ausente_split).to eql("000000000000180")
      expect(com_split.valor_repassado_novo_titular).to eql("000000000000180")
      expect(com_split.valor_residual).to eql("000000000000000")
    end

    it "associa os registros X-03/X-04 ao titulo que eles acompanham, e nao ao proximo" do
      sem_split = retornos.last

      expect(sem_split.nosso_numero).to eql("87654321")
      expect(sem_split.documento_fiscal).to be_nil
      expect(sem_split.id_split).to be_nil
      expect(sem_split.valor_pago_ausente_split).to be_nil
    end

    it "ignora outros registros opcionais do segmento X" do
      # O segmento X e usado pelos registros do Split Payment de outros
      # processos, identificados pelo campo 16-17 (tabela G067): o X-01, por
      # exemplo, e o Split Payment da visao do Pagador (pagamentos).
      outro_opcional = Tempfile.new(["retorno_itau_x", ".RET"])
      linhas = File.read(arquivo).split("\r\n").reject(&:blank?)
      linhas[3] = linhas[3].dup
      linhas[3][15..16] = "05"
      outro_opcional.write("#{linhas.join("\r\n")}\r\n")
      outro_opcional.rewind

      com_outro_opcional = described_class.load_lines(outro_opcional.path).first

      expect(com_outro_opcional.nosso_numero).to eql("12345678")
      expect(com_outro_opcional.documento_fiscal).to be_nil
      expect(com_outro_opcional.id_split).to be_nil
    ensure
      outro_opcional.close
      outro_opcional.unlink
    end
  end
end
