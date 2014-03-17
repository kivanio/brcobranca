# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Brcobranca::Retorno::RetornoCnab400 do
  before(:each) do
    @arquivo = File.join(File.dirname(__FILE__), '..', 'arquivos', 'CNAB400.RET')
  end

  it 'Ignora primeira linha que é header' do
    pagamentos = Brcobranca::Retorno::RetornoCnab400.load_lines(@arquivo)
    pagamento = pagamentos.first
    pagamento.sequencial.should eql('000002')
  end

  it 'Transforma arquivo de retorno em objetos de retorno retornando somente as linhas de pagamentos de títulos sem registro' do
    pagamentos = Brcobranca::Retorno::RetornoCnab400.load_lines(@arquivo)
    pagamentos.size.should == 53 #deve ignorar a primeira linha que é header
    pagamento = pagamentos.first
    pagamento.agencia_com_dv.should eql('0730')
    pagamento.beneficiario_com_dv.should eql('035110')
    pagamento.nosso_numero.should eql('00000011')
    pagamento.carteira_variacao.should eql('109')
    pagamento.carteira.should eql('I')
    pagamento.data_vencimento.should eql('000000')
    pagamento.valor_titulo.should eql('0000000004000')
    pagamento.banco_recebedor.should eql('104')
    pagamento.agencia_recebedora_com_dv.should eql('18739')
    pagamento.especie_documento.should eql('')
    pagamento.valor_tarifa.should eql('0000000000210')
    pagamento.iof.should eql('0000000000000')
    pagamento.valor_abatimento.should eql('0000000000000')
    pagamento.desconto.should eql('0000000000000')
    pagamento.valor_recebido.should eql('0000000003790')
    pagamento.juros_mora.should eql('0000000000000')
    pagamento.outros_recebimento.should eql('0000000000000')
    pagamento.data_credito.should eql('210513')
    pagamento.sequencial.should eql('000002')

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


