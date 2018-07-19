# -*- encoding: utf-8 -*-
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
end
