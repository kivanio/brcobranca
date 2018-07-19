# -*- encoding: utf-8 -*-
require 'spec_helper'

RSpec.describe Brcobranca::Retorno::Cnab400::Itau do
  before do
    @arquivo = File.join(File.dirname(__FILE__), '..', '..', '..', 'arquivos', 'CNAB400ITAU.RET')
  end

  it 'Ignora primeira linha que é header' do pagamentos = described_class.load_lines(@arquivo)
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
    expect(pagamento.carteira_variacao).to eql('109')
    expect(pagamento.carteira).to eql('I')
    expect(pagamento.data_vencimento).to eql('000000')
    expect(pagamento.valor_titulo).to eql('0000000004000')
    expect(pagamento.banco_recebedor).to eql('104')
    expect(pagamento.agencia_recebedora_com_dv).to eql('18739')
    expect(pagamento.especie_documento).to eql('')
    expect(pagamento.valor_tarifa).to eql('0000000000210')
    expect(pagamento.iof).to eql('0000000000000')
    expect(pagamento.valor_abatimento).to eql('0000000000000')
    expect(pagamento.desconto).to eql('0000000000000')
    expect(pagamento.valor_recebido).to eql('0000000003790')
    expect(pagamento.juros_mora).to eql('0000000000000')
    expect(pagamento.outros_recebimento).to eql('0000000000000')
    expect(pagamento.codigo_ocorrencia).to eql('06')
    expect(pagamento.data_ocorrencia).to eql('200513')
    expect(pagamento.data_credito).to eql('210513')
    expect(pagamento.motivo_ocorrencia).to eql([])
    expect(pagamento.sequencial).to eql('000002')

    # Campos da classe base que não encontrei a relação com CNAB400
    # parse.field :tipo_cobranca,80..80
    # parse.field :tipo_cobranca_anterior,81..81
    # parse.field :natureza_recebimento,86..87
    # parse.field :convenio,31..37
    # parse.field :comando,108..109
    # parse.field :juros_desconto,201..213
    # parse.field :iof_desconto,214..226
    # parse.field :desconto_concedito,240..252
    # parse.field :outras_despesas,279..291
    # parse.field :abatimento_nao_aproveitado,292..304
    # parse.field :data_liquidacao,295..300
    # parse.field :valor_lancamento,305..317
    # parse.field :indicativo_lancamento,318..318
    # parse.field :indicador_valor,319..319
    # parse.field :valor_ajuste,320..331
  end
end
