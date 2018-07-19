# -*- encoding: utf-8 -*-
require 'spec_helper'

RSpec.describe Brcobranca::Retorno::Cnab400::Unicred do
  before do
    @arquivo = File.join(File.dirname(__FILE__), '..', '..', '..', 'arquivos', 'CNAB400UNICRED.RET')
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

    expect(pagamento.sequencial).to eql('000002')
    expect(pagamento.agencia_sem_dv).to eql('4205')
    expect(pagamento.cedente_com_dv).to eql('60001566')
    expect(pagamento.nosso_numero).to eql('00000116')
    expect(pagamento.carteira).to eql('5')
    expect(pagamento.data_vencimento).to eql('130515')
    expect(pagamento.valor_titulo).to eql('0000000044400')
    expect(pagamento.banco_recebedor).to eql('090')
    expect(pagamento.agencia_recebedora_com_dv).to eql('42050')
    expect(pagamento.especie_documento).to eql('01')
    expect(pagamento.valor_tarifa).to eql('0000000000160')
    expect(pagamento.iof).to eql('0000000000000')
    expect(pagamento.valor_abatimento).to eql('0000000000000')
    expect(pagamento.desconto).to eql('0000000000000')
    expect(pagamento.juros_mora).to eql('0000000000000')
    expect(pagamento.outros_recebimento).to eql('0000000000000')
    expect(pagamento.codigo_ocorrencia).to eql('06')
    expect(pagamento.data_ocorrencia).to eql('150515')
    expect(pagamento.valor_recebido).to eql('0000000044400')
    expect(pagamento.data_credito).to eql('150515')
    expect(pagamento.motivo_ocorrencia).to eql(['20'])
  end
end
