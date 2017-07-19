# -*_ encoding: utf-8 -*-
#
RSpec.describe Brcobranca::Retorno::Cnab240::Sicoob do
  before do
    @arquivo = File.join(File.dirname(__FILE__), '..', '..', '..', 'arquivos', 'CNAB240SICOOB.RET')
    @arquivo_com_cod = File.join(File.dirname(__FILE__), '..', '..', '..', 'arquivos', 'CNAB240SICOOB_COM_CODIGOS.RET')
  end

  it 'Transforma arquivo de retorno em objetos de retorno retornando somente as linhas de pagamentos de titulos sem registro' do
    pagamentos = described_class.load_lines(@arquivo)
    expect(pagamentos.size).to eq(3)
    pagamento = pagamentos.first
    expect(pagamento.agencia_com_dv).to eql('030390')
    expect(pagamento.cedente_com_dv).to eql('0000000489816')
    expect(pagamento.nosso_numero).to eql('0000000083')
    expect(pagamento.numero_documento).to eql('000000000123456')
    expect(pagamento.carteira).to eql('1')
    expect(pagamento.data_vencimento).to eql('13082015')
    expect(pagamento.valor_titulo).to eql('000000000000200')
    expect(pagamento.banco_recebedor).to eql('756')
    expect(pagamento.agencia_recebedora_com_dv).to eql('030390')
    expect(pagamento.data_credito).to eql('10082015')
    expect(pagamento.outras_despesas).to eql('000000000000000')
    expect(pagamento.iof_desconto).to eql('000000000000000')
    expect(pagamento.valor_abatimento).to eql('000000000000000')
    expect(pagamento.desconto_concedito).to eql('000000000000000')
    expect(pagamento.valor_recebido).to eql('000000000000200')
    expect(pagamento.juros_mora).to eql('000000000000000')
    expect(pagamento.outros_recebimento).to eql('000000000000000')
    expect(pagamento.sequencial).to eql('00001')
    expect(pagamento.valor_tarifa).to eql('000000000000170')

    # Dados que não consegui extrair dos registros T e U
    # pagamento.convenio.should eql("")
    # pagamento.tipo_cobranca.should eql("")
    # pagamento.tipo_cobranca_anterior.should eql("")
    # pagamento.natureza_recebimento.should eql("")
    # pagamento.carteira_variacao.should eql("7")
    # pagamento.iof.should eql("")
    # pagamento.comando.should eql("")
    # pagamento.data_liquidacao.should eql("")
    # pagamento.especie_documento.should eql("")
    # pagamento.valor_tarifa.should eql("")
    # pagamento.juros_desconto.should eql("")
    # pagamento.abatimento_nao_aproveitado.should eql("")
    # pagamento.valor_lancamento.should eql("")
    # pagamento.indicativo_lancamento.should eql("")
    # pagamento.indicador_valor.should eql("")
    # pagamento.valor_ajuste.should eql("")
  end

  it 'configura codigos de movimento de retorno e motivo da ocorrencia' do
    pagamentos = described_class.load_lines(@arquivo_com_cod)

    pagamento = pagamentos[0]
    expect(pagamento.cod_movimento_ret).to eql('06')
    expect(pagamento.motivos_ocorrencia).to eql(['A9','A4','15','22','16'])

    pagamento = pagamentos[1]
    expect(pagamento.cod_movimento_ret).to eql('02')
    expect(pagamento.motivos_ocorrencia).to eql(['03','11'])

    pagamento = pagamentos[2]
    expect(pagamento.cod_movimento_ret).to eql('17')
    expect(pagamento.motivos_ocorrencia).to eql([])
  end
end

