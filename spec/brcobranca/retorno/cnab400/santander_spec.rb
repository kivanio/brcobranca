# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Brcobranca::Retorno::Cnab400::Santander do
  let(:file) { File.join(File.dirname(__FILE__), '..', '..', '..', 'arquivos', 'CNAB400SANTANDER.RET') }
  let(:pagamentos) { described_class.load_lines(file) }

  it 'Ignora primeira linha que é header' do
    pagamento = pagamentos.first

    expect(pagamento.sequencial).to eql('000002')
  end

  it 'Transforma arquivo de retorno em objetos de retorno retornando somente as linhas de pagamentos de títulos sem registro' do
    expect(pagamentos.size).to eq(54) # deve ignorar a primeira linha que é header
  end

  it 'Faz o parser de todos os detalhes corretamente' do
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

  it 'Fez o parser de todos os detalhes de um pagamento PIX corretamente' do
    pagamento = pagamentos[52]

    expect(pagamento.codigo_registro).to eql('2')
    expect(pagamento.tipo_chave_dict).to eql('1')
    expect(pagamento.codigo_chave_dict).to eql('12345678901')
    expect(pagamento.txid).to eql('d48c95197d6ec3985b89bc3ccb3351')
  end
end
