# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Brcobranca::Retorno::RetornoCnab240 do
  before do
    @arquivo = File.join(File.dirname(__FILE__), '..', '..', 'arquivos', 'CNAB240.RET')
  end

  it 'Transforma arquivo de retorno em objetos de retorno retornando somente as linhas de pagamentos de títulos sem registro' do
    pagamentos = described_class.load_lines(@arquivo)
    expect(pagamentos.size).to eq(35)
    pagamento = pagamentos.first
    expect(pagamento.agencia_com_dv).to eql('012345')
    expect(pagamento.cedente_com_dv).to eql('0000000054321')
    expect(pagamento.nosso_numero).to eql('00020673')
    expect(pagamento.carteira).to eql('7')
    expect(pagamento.data_vencimento).to eql('00000000')
    expect(pagamento.valor_titulo).to eql('000000000034400')
    expect(pagamento.banco_recebedor).to eql('001')
    expect(pagamento.agencia_recebedora_com_dv).to eql('020850')
    # expect(pagamento.data_ocorrencia).to eql('02012012')
    expect(pagamento.data_credito).to eql('02012012')
    expect(pagamento.outras_despesas).to eql('000000000000004')
    expect(pagamento.iof_desconto).to eql('000000000000003')
    expect(pagamento.valor_abatimento).to eql('000000000000002')
    expect(pagamento.desconto_concedito).to eql('000000000000001')
    expect(pagamento.valor_recebido).to eql('000000000034400')
    expect(pagamento.juros_mora).to eql('000000000000009')
    expect(pagamento.outros_recebimento).to eql('000000000000005')
    expect(pagamento.sequencial).to eql('00001')
    expect(pagamento.valor_tarifa).to eql('000000000000103')
    expect(pagamento.motivo_ocorrencia).to eql(['03'])

    # Dados que não consegui extrair dos registros T e U
    # pagamento.convenio.should eql('')
    # pagamento.tipo_cobranca.should eql('')
    # pagamento.tipo_cobranca_anterior.should eql('')
    # pagamento.natureza_recebimento.should eql('')
    # pagamento.carteira_variacao.should eql('7')
    # pagamento.iof.should eql('')
    # pagamento.comando.should eql('')
    # pagamento.data_liquidacao.should eql('')
    # pagamento.especie_documento.should eql('')
    # pagamento.valor_tarifa.should eql('')
    # pagamento.juros_desconto.should eql('')
    # pagamento.abatimento_nao_aproveitado.should eql('')
    # pagamento.valor_lancamento.should eql('')
    # pagamento.indicativo_lancamento.should eql('')
    # pagamento.indicador_valor.should eql('')
    # pagamento.valor_ajuste.should eql('')
  end

  # Os registros opcionais do Split Payment (IBS/CBS) sao o padrao Febraban
  # (Segmento X-03 + X-04 no Layout Padrao 240 posicoes V11.0) e valem tambem
  # para o layout generico do CNAB 240, usado pelos bancos que nao tem classe
  # propria de retorno (ex.: Caixa).
  describe 'Segmento X-03 e X-04 (Split Payment IBS/CBS)' do
    let(:arquivo) do
      File.join(File.dirname(__FILE__), '..', '..', 'arquivos', 'CNAB240ITAU-SPLIT-PAYMENT.RET')
    end

    it 'le os campos do Split Payment do titulo que tem os registros' do
      retornos = described_class.load_lines(arquivo)

      expect(retornos.size).to eq(2)
      expect(retornos.first.identificacao_registro_opcional).to eql('03')
      expect(retornos.first.documento_fiscal).
        to eql('35260647906085000135550010000012341000012345')
      expect(retornos.first.valor_cbs_segregado).to eql('000000000000180')
      expect(retornos.first.valor_ibs_segregado).to eql('000000000000020')
      expect(retornos.first.id_split).to eql('E2E12345678901234567890123456789012')
      expect(retornos.first.tipo_id_split).to eql('E2E')
      expect(retornos.first.valor_pago_ausente_split).to eql('000000000000180')
      expect(retornos.first.valor_repassado_novo_titular).to eql('000000000000180')
      expect(retornos.first.valor_residual).to eql('000000000000000')
      expect(retornos.last.documento_fiscal).to be_nil
    end
  end

  describe 'arquivo sem o par T/U' do
    # Os registros opcionais (Y/X) nao iniciam um titulo no arquivo de retorno:
    # um arquivo que so tem esses segmentos (ex.: Retorno de Boleto de
    # Pagamento, com G, H, Y e X) nao gera retorno nenhum.
    let(:arquivo_sem_t_u) do
      Tempfile.new(['retorno_cnab240_sem_t_u', '.RET']).tap do |arquivo|
        arquivo.write("3410001300001Y 03#{' ' * 222}\r\n")
        arquivo.rewind
      end
    end

    after do
      arquivo_sem_t_u.close
      arquivo_sem_t_u.unlink
    end

    it 'nao gera retorno para os registros opcionais sem o titulo' do
      expect(described_class.load_lines(arquivo_sem_t_u.path)).to eq []
    end
  end

  describe 'registros opcionais do Split Payment de outro lote' do
    # Os registros X-03/X-04 acompanham o titulo do mesmo lote: um lote sem o
    # par T/U (ex.: o lote de G/H do Pagamento de Boleto, cujos segmentos sao
    # descartados pelo filtro) nao pode ter os seus dados do Split Payment
    # lidos como se fossem do titulo do lote anterior.
    let(:arquivo_split) do
      File.join(File.dirname(__FILE__), '..', '..', 'arquivos', 'CNAB240ITAU-SPLIT-PAYMENT.RET')
    end
    let(:arquivo_outro_lote) do
      Tempfile.new(['retorno_cnab240_outro_lote', '.RET']).tap do |arquivo|
        linhas = File.read(arquivo_split).split("\r\n")
        # Os registros opcionais do primeiro titulo passam para o lote 0002,
        # que nao tem o par T/U no arquivo
        linhas[3][3..6] = '0002'
        linhas[4][3..6] = '0002'
        arquivo.write("#{linhas.join("\r\n")}\r\n")
        arquivo.rewind
      end
    end

    after do
      arquivo_outro_lote.close
      arquivo_outro_lote.unlink
    end

    it 'nao associa os registros do Split Payment ao titulo do lote anterior' do
      retornos = described_class.load_lines(arquivo_outro_lote.path)

      expect(retornos.size).to eq(2)
      expect(retornos.first.documento_fiscal).to be_nil
      expect(retornos.first.valor_pago_ausente_split).to be_nil
    end
  end
end
