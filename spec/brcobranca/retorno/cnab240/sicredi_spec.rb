RSpec.describe Brcobranca::Retorno::Cnab240::Sicredi do
  before do
    @arquivo = File.join(File.dirname(__FILE__), '..', '..', '..', 'arquivos', 'CNAB240SICREDI.CRT')
  end

  it 'Transforma arquivo de retorno em objetos de retorno retornando somente as linhas de pagamentos de títulos sem registro' do
    pagamentos = described_class.load_lines(@arquivo)
    expect(pagamentos.size).to eq(2)
    pagamento = pagamentos.first
    expect(pagamento.agencia_com_dv).to eql('00390')
    expect(pagamento.cedente_com_dv).to eql('0000000041468')
    expect(pagamento.nosso_numero).to eql('172000595')
    expect(pagamento.carteira).to eql('1')
    expect(pagamento.data_vencimento).to eql('13042017')
    expect(pagamento.valor_titulo).to eql('000000000000995')
    expect(pagamento.banco_recebedor).to eql('000')
    expect(pagamento.codigo_ocorrencia).to eql('02')
    expect(pagamento.data_ocorrencia).to eql('06042017')
    expect(pagamento.data_credito).to eql('')
    expect(pagamento.outras_despesas).to eql('000000000000000')
    expect(pagamento.iof_desconto).to eql('000000000000000')
    expect(pagamento.valor_abatimento).to eql('000000000000000')
    expect(pagamento.desconto_concedito).to eql('000000000000000')
    expect(pagamento.valor_recebido).to eql('000000000000000')
    expect(pagamento.juros_mora).to eql('000000000000000')
    expect(pagamento.outros_recebimento).to eql('000000000000000')
    expect(pagamento.sequencial).to eql('00001')
    expect(pagamento.valor_tarifa).to eql('000000000000000')
    expect(pagamento.motivo_ocorrencia).to eql(['A4'])
  end
end
