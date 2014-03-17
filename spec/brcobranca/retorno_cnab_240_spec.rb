# -*- encoding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Brcobranca::Retorno::RetornoCnab240 do
  before(:each) do
    @arquivo = File.join(File.dirname(__FILE__), '..', 'arquivos', 'CNAB240.RET')
  end

  it 'Transforma arquivo de retorno em objetos de retorno retornando somente as linhas de pagamentos de títulos sem registro' do
    pagamentos = Brcobranca::Retorno::RetornoCnab240.load_lines(@arquivo)
    pagamentos.size.should == 35
    pagamento = pagamentos.first
    pagamento.agencia_com_dv.should eql('012345')
    pagamento.beneficiario_com_dv.should eql('0000000054321')
    pagamento.nosso_numero.should eql('00020673')
    pagamento.carteira.should eql('7')
    pagamento.data_vencimento.should eql('00000000')
    pagamento.valor_titulo.should eql('000000000034400')
    pagamento.banco_recebedor.should eql('001')
    pagamento.agencia_recebedora_com_dv.should eql('020850')
    pagamento.data_credito.should eql('02012012')
    pagamento.outras_despesas.should eql('000000000000004')
    pagamento.iof_desconto.should eql('000000000000003')
    pagamento.valor_abatimento.should eql('000000000000002')
    pagamento.desconto_concedito.should eql('000000000000001')
    pagamento.valor_recebido.should eql('000000000034400')
    pagamento.juros_mora.should eql('000000000000009')
    pagamento.outros_recebimento.should eql('000000000000005')
    pagamento.sequencial.should eql('00001')
    pagamento.valor_tarifa.should eql('000000000000103')

    # Dados que não consegui extrair dos registros T e U
    #pagamento.convenio.should eql('')
    #pagamento.tipo_cobranca.should eql('')
    #pagamento.tipo_cobranca_anterior.should eql('')
    #pagamento.natureza_recebimento.should eql('')
    #pagamento.carteira_variacao.should eql('7')
    #pagamento.iof.should eql('')
    #pagamento.comando.should eql('')
    #pagamento.data_liquidacao.should eql('')
    #pagamento.especie_documento.should eql('')
    #pagamento.valor_tarifa.should eql('')
    #pagamento.juros_desconto.should eql('')
    #pagamento.abatimento_nao_aproveitado.should eql('')
    #pagamento.valor_lancamento.should eql('')
    #pagamento.indicativo_lancamento.should eql('')
    #pagamento.indicador_valor.should eql('')
    #pagamento.valor_ajuste.should eql('')
  end
end


