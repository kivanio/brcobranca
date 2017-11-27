# -*_ encoding: utf-8 -*-
#
require 'spec_helper'
RSpec.describe Brcobranca::Retorno::Cnab240::Santander do
  before do
    @arquivo = File.join(File.dirname(__FILE__), '..', '..', '..', 'arquivos', 'CNAB240SANTANDER.RET')
  end

  it 'Transforma arquivo de retorno em objetos de retorno retornando somente as linhas de pagamentos de titulos sem registro' do
    pagamentos = described_class.load_lines(@arquivo)
    expect(pagamentos.size).to eq(6)
    pagamento = pagamentos.last
    expect(pagamento.agencia_com_dv).to eql('999991')
    expect(pagamento.nosso_numero_com_dv).to eql('0000000289647')
    expect(pagamento.nosso_numero).to eql('000000028964')
    expect(pagamento.carteira).to eql('1')
    expect(pagamento.data_vencimento).to eql('28042016')
    expect(pagamento.valor_titulo).to eql('000000000000126')
    expect(pagamento.banco_recebedor).to eql('001')
    expect(pagamento.agencia_recebedora_com_dv).to eql('1234')
    expect(pagamento.data_credito).to eql('29042016')
    expect(pagamento.outras_despesas).to eql('000000000000000')
    expect(pagamento.iof_desconto).to eql('000000000000000')
    expect(pagamento.valor_abatimento).to eql('000000000000000')
    expect(pagamento.desconto_concedito).to eql('000000000000000')
    expect(pagamento.valor_recebido).to eql('000000000000126')
    expect(pagamento.juros_mora).to eql('000000000000000')
    expect(pagamento.outros_recebimento).to eql('000000000000000')
    expect(pagamento.sequencial).to eql('00011')
    expect(pagamento.valor_tarifa).to eql('000000000000600')
    expect(pagamento.data_ocorrencia).to eql('28042016')
    expect(pagamento.codigo_ocorrencia).to eql('17')
    expect(pagamento.motivo_ocorrencia).to eql([])
  end
end
