# -*- encoding: utf-8 -*-
shared_examples_for 'cnab400' do
  let(:pagamento) do
    Brcobranca::Remessa::Pagamento.new(valor: 199.9,
      data_vencimento: Date.today,
      nosso_numero: 123,
      documento_sacado: '12345678901',
      nome_sacado: 'PABLO DIEGO JOSÉ FRANCISCO DE PAULA JUAN NEPOMUCENO MARÍA DE LOS REMEDIOS CIPRIANO DE LA SANTÍSSIMA TRINIDAD RUIZ Y PICASSO',
      endereco_sacado: 'RUA RIO GRANDE DO SUL São paulo Minas caçapa da silva junior',
      bairro_sacado: 'São josé dos quatro apostolos magros',
      cep_sacado: '12345678',
      cidade_sacado: 'Santa rita de cássia maria da silva',
      nome_avalista: 'ISABEL CRISTINA LEOPOLDINA ALGUSTA MIGUELA GABRIELA RAFAELA GONZAGA DE BRAGANÇA E BOURBON',
      uf_sacado: 'SP')
  end
  let(:params) do
    if subject.class == Brcobranca::Remessa::Cnab400::Bradesco
      { carteira: '01',
        agencia: '12345',
        conta_corrente: '1234567',
        digito_conta: '1',
        empresa_mae: 'SOCIEDADE BRASILEIRA DE ZOOLOGIA LTDA',
        sequencial_remessa: '1',
        codigo_empresa: '123',
        pagamentos: [pagamento] }
    elsif subject.class == Brcobranca::Remessa::Cnab400::Citibank
      {
        portfolio: '17777751042700080112',
        carteira: '1',
        empresa_mae: 'SOCIEDADE BRASILEIRA DE ZOOLOGIA LTDA',
        documento_cedente: '12345678910',
        pagamentos: [pagamento]
      }
    elsif subject.class == Brcobranca::Remessa::Cnab400::Santander
      {
        codigo_transmissao: '17777751042700080112',
        empresa_mae: 'SOCIEDADE BRASILEIRA DE ZOOLOGIA LTDA',
        documento_cedente: '12345678910',
        agencia: '8888',
        conta_corrente: '000002997',
        digito_conta: '8',
        pagamentos: [pagamento]
      }
    elsif subject.class == Brcobranca::Remessa::Cnab400::Sicoob
      { carteira: '01',
        agencia: '1234',
        conta_corrente: '12345678',
        digito_conta: '1',
        empresa_mae: 'SOCIEDADE BRASILEIRA DE ZOOLOGIA LTDA',
        documento_cedente: '12345678910',
        convenio: '123456789',
        pagamentos: [pagamento] }
    else
      { carteira: '123',
        agencia: '4327',
        conta_corrente: '12345',
        digito_conta: '1',
        empresa_mae: 'SOCIEDADE BRASILEIRA DE ZOOLOGIA LTDA',
        documento_cedente: '12345678910',
        pagamentos: [pagamento] }
    end
  end
  let(:objeto) { subject.class.new(params) }

  it 'header deve ter 400 posicoes' do
    expect(objeto.monta_header.size).to eq 400
  end

  it 'detalhe deve falhar se pagamento nao for valido' do
    expect { objeto.monta_detalhe(Brcobranca::Remessa::Pagamento.new, 1) }.to raise_error(Brcobranca::RemessaInvalida)
  end

  it 'detalhe deve ter 400 posicoes' do
    expect(objeto.monta_detalhe(pagamento, 1).size).to eq 400
  end

  context 'trailer' do
    it 'trailer deve ter 400 posicoes' do
      expect(objeto.monta_trailer(1).size).to eq 400
    end

    it 'informacoes devem estar posicionadas corretamente no trailer' do
      trailer = objeto.monta_trailer 3
      expect(trailer[0]).to eq '9' # identificacao registro
      expect(trailer[394..399]).to eq '000003' # numero sequencial do registro
    end
  end

  it 'montagem da remessa deve falhar se o objeto nao for valido' do
    expect { subject.class.new.gera_arquivo }.to raise_error(Brcobranca::RemessaInvalida)
  end

  it 'remessa deve conter os registros mais as quebras de linha' do
    remessa = objeto.gera_arquivo
    expect(remessa.size).to eq 1206

    # registros
    expect(remessa[0..399]).to eq objeto.monta_header
    expect(remessa[402..801]).to eq objeto.monta_detalhe(pagamento, 2).upcase
    expect(remessa[804..1203]).to eq objeto.monta_trailer(3)
    # quebras de linha
    expect(remessa[400..401]).to eq "\r\n"
    expect(remessa[802..803]).to eq "\r\n"
  end

  it 'deve ser possivel adicionar mais de um pagamento' do
    objeto.pagamentos << pagamento
    remessa = objeto.gera_arquivo

    expect(remessa.size).to eq 1608
  end
end
