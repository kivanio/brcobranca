# -*_ encoding: utf-8 -*-
#
require 'spec_helper'
RSpec.describe Brcobranca::Retorno::Cnab240::Cecred do
  before do
    @arquivo = File.join(File.dirname(__FILE__), '..', '..', '..', 'arquivos', 'CNAB240CECRED.RET')
  end

  it 'Transforma arquivo de retorno em objetos de retorno retornando somente as linhas de pagamentos de titulos sem registro' do
    pagamentos = described_class.load_lines(@arquivo)
    expect(pagamentos.size).to eq(6)
    pagamento = pagamentos.last
    expect(pagamento.agencia_com_dv).to eql('012345')
    expect(pagamento.nosso_numero).to eql('14499570000020830')
    expect(pagamento.carteira).to eql('7')
    expect(pagamento.data_vencimento).to eql('00000000')
    expect(pagamento.valor_titulo).to eql('000000000206255')
    expect(pagamento.banco_recebedor).to eql('237')
    expect(pagamento.agencia_recebedora_com_dv).to eql('011020')
    expect(pagamento.data_credito).to eql('02012012')
    expect(pagamento.outras_despesas).to eql('000000000000000')
    expect(pagamento.iof_desconto).to eql('000000000000000')
    expect(pagamento.valor_abatimento).to eql('000000000000000')
    expect(pagamento.desconto_concedito).to eql('000000000000000')
    expect(pagamento.valor_recebido).to eql('000000000206255')
    expect(pagamento.juros_mora).to eql('000000000000000')
    expect(pagamento.outros_recebimento).to eql('000000000000000')
    expect(pagamento.sequencial).to eql('00011')
    expect(pagamento.valor_tarifa).to eql('000000000000103')
  end
end
