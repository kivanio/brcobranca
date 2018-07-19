# -*- encoding: utf-8 -*-
require 'spec_helper'

RSpec.describe Brcobranca::Retorno::Cnab400::Credisis do
  before do
    @arquivo = File.join(File.dirname(__FILE__), '..', '..', '..', 'arquivos', 'CNAB400CREDISIS.RET')
  end

  it 'Ignora primeira linha que é header' do
    pagamentos = described_class.load_lines(@arquivo)
    pagamento = pagamentos.first
    expect(pagamento.sequencial).to eql('000002')
  end

  it 'Transforma arquivo de retorno em objetos de retorno retornando somente as linhas de pagamentos de títulos sem registro' do
    pagamentos = described_class.load_lines(@arquivo)
    expect(pagamentos.size).to eq(2) # deve ignorar a primeira linha que é header
    pagamento = pagamentos.first
    expect(pagamento.nosso_numero).to eql("00005005001")
    expect(pagamento.data_vencimento).to eql("011012")
    expect(pagamento.valor_titulo).to eql("0000005005001")
    expect(pagamento.valor_recebido).to eql('0000000044400')
    expect(pagamento.data_credito).to eql('150515')
  end
end
