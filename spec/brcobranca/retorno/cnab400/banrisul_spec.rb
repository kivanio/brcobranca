# -*- encoding: utf-8 -*-
require 'spec_helper'

RSpec.describe Brcobranca::Retorno::Cnab400::Banrisul do
  before do
    @arquivo = File.join(File.dirname(__FILE__), '..', '..', '..', 'arquivos', 'CNAB400BANRISUL.RET')
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
    expect(pagamento.agencia_sem_dv).to eql('1102')
    expect(pagamento.cedente_com_dv).to eql('900015096')
    expect(pagamento.nosso_numero).to eql('2283256350')
    expect(pagamento.carteira).to eql('1')
    expect(pagamento.codigo_ocorrencia).to eql('06')
    expect(pagamento.data_ocorrencia).to eql('150515')
    expect(pagamento.data_vencimento).to eql('250515')
    expect(pagamento.valor_titulo).to eql('0000000145000')
    expect(pagamento.banco_recebedor).to eql('041')
    expect(pagamento.agencia_recebedora_com_dv).to eql('1102')
    expect(pagamento.especie_documento).to eql('')
    expect(pagamento.valor_tarifa).to eql('0000000000160')
    expect(pagamento.iof).to eql('0000000000000')
    expect(pagamento.valor_abatimento).to eql('0000000000000')
    expect(pagamento.desconto).to eql('0000000000000')
    expect(pagamento.valor_recebido).to eql('0000000145000')
    expect(pagamento.juros_mora).to eql('0000000000000')
    expect(pagamento.outros_recebimento).to eql('0000000000000')
    expect(pagamento.data_credito).to eql('150515')
    expect(pagamento.motivo_ocorrencia).to eql('')
    expect(pagamento.sequencial).to eql('000002')
  end
end
