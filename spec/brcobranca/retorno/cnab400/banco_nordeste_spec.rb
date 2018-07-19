# -*- encoding: utf-8 -*-
require 'spec_helper'

RSpec.describe Brcobranca::Retorno::Cnab400::BancoNordeste do
  before do
    @arquivo = File.join(File.dirname(__FILE__), '..', '..', '..', 'arquivos', 'CNAB400BANCONORDESTE.RET')
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

    expect(pagamento.agencia_sem_dv).to eql('0217')
    expect(pagamento.cedente_com_dv).to eql('00056911')
    expect(pagamento.nosso_numero).to eql('00000116')
    expect(pagamento.valor_recebido).to eql('0000000017500')
    expect(pagamento.carteira).to eql('I')
    expect(pagamento.codigo_ocorrencia).to eql('06')
    expect(pagamento.data_ocorrencia).to eql('191114')
    expect(pagamento.data_vencimento).to eql('191114')
    expect(pagamento.valor_titulo).to eql('0000000017500')
    expect(pagamento.banco_recebedor).to eql('004')
    expect(pagamento.especie_documento).to eql('01')
    expect(pagamento.valor_tarifa).to eql('0000000000260')
    expect(pagamento.valor_abatimento).to eql('0000000000000')
    expect(pagamento.desconto).to eql('0000000000000')
    expect(pagamento.valor_recebido).to eql('0000000017500')
    expect(pagamento.juros_mora).to eql('0000000000000')
    expect(pagamento.data_credito).to eql('191114')
    expect(pagamento.motivo_ocorrencia).to eql('00000000000000000011100000000000000000000000000000000000000000000000000000000')
  end
end
