# -*- encoding: utf-8 -*-
require 'spec_helper'

RSpec.describe Brcobranca::Retorno::Cnab400::Santander do
  before do
    @arquivo = File.join(File.dirname(__FILE__), '..', '..', '..', 'arquivos', 'CNAB400SANTANDER.RET')
  end

  it 'Ignora primeira linha que é header' do
    pagamentos = described_class.load_lines(@arquivo)
    pagamento = pagamentos.first
    expect(pagamento.sequencial).to eql('000002')
  end

  it 'Transforma arquivo de retorno em objetos de retorno retornando somente as linhas de pagamentos de títulos sem registro' do
    pagamentos = described_class.load_lines(@arquivo)
    expect(pagamentos.size).to eq(53) # deve ignorar a primeira linha que é header
    pagamento = pagamentos.first
    expect(pagamento.agencia_com_dv).to eql('0730')
    expect(pagamento.cedente_com_dv).to eql('035110')
    expect(pagamento.nosso_numero).to eql('00000011')
    expect(pagamento.carteira).to eql('I')
    expect(pagamento.data_vencimento).to eql('000000')
    expect(pagamento.valor_titulo).to eql('0000000004000')
    expect(pagamento.banco_recebedor).to eql('033')
    expect(pagamento.agencia_recebedora_com_dv).to eql('18739')
    expect(pagamento.especie_documento).to eql('')
    expect(pagamento.valor_tarifa).to eql('0000000000210')
    expect(pagamento.iof).to eql('0000000000000')
    expect(pagamento.valor_abatimento).to eql('0000000000000')
    expect(pagamento.desconto).to eql('0000000000000')
    expect(pagamento.valor_recebido).to eql('0000000003790')
    expect(pagamento.juros_mora).to eql('0000000000000')
    expect(pagamento.outros_recebimento).to eql('0000000000000')
    expect(pagamento.data_credito).to eql('210513')
    expect(pagamento.motivo_ocorrencia).to eql([])
    expect(pagamento.sequencial).to eql('000002')
  end
end
