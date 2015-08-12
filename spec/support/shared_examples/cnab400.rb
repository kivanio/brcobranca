# -*- encoding: utf-8 -*-
shared_examples_for 'cnab400' do
  let(:pagamento) do
    Brcobranca::Remessa::Pagamento.new(valor: 199.9,
                                       data_vencimento: Date.today,
                                       nosso_numero: 123,
                                       documento_sacado: '12345678901',
                                       nome_sacado: 'nome',
                                       endereco_sacado: 'endereco',
                                       bairro_sacado: 'bairro',
                                       cep_sacado: '12345678',
                                       cidade_sacado: 'cidade',
                                       uf_sacado: 'SP')
  end
  let(:params) do
    if subject.class == Brcobranca::Remessa::Cnab400::Bradesco
      { carteira: '01',
        agencia: '12345',
        conta_corrente: '1234567',
        digito_conta: '1',
        empresa_mae: 'ASD',
        sequencial_remessa: '1',
        codigo_empresa: '123',
        pagamentos: [pagamento] }
    elsif subject.class == Brcobranca::Remessa::Cnab400::Citibank
      {
        portfolio: '17777751042700080112',
        carteira: '1',
        empresa_mae: 'ASD',
        documento_cedente: '12345678910',
        pagamentos: [pagamento]
      }
    elsif subject.class == Brcobranca::Remessa::Cnab400::Santander
      {
        codigo_transmissao: '17777751042700080112',
        empresa_mae: 'ASD',
        documento_cedente: '12345678910',
        pagamentos: [pagamento]
      }
    else
      { carteira: '123',
        agencia: '1234',
        conta_corrente: '12345',
        digito_conta: '1',
        empresa_mae: 'ASD',
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
      expect(trailer[0]).to eq '9'                       # identificacao registro
      expect(trailer[1..393]).to eq ''.rjust(393, ' ')   # brancos
      expect(trailer[394..399]).to eq '000003'           # numero sequencial do registro
    end
  end

  it 'montagem da remessa deve falhar se o objeto nao for valido' do
    expect { subject.class.new.gera_arquivo }.to raise_error(Brcobranca::RemessaInvalida)
  end

  it 'remessa deve conter os registros mais as quebras de linha' do
    remessa = objeto.gera_arquivo
    expect(remessa.size).to eq 1202

    # registros
    expect(remessa[0..399]).to eq objeto.monta_header
    expect(remessa[401..800]).to eq objeto.monta_detalhe(pagamento, 2)
    expect(remessa[802..1201]).to eq objeto.monta_trailer(3)
    # quebras de linha
    expect(remessa[400]).to eq "\n"
    expect(remessa[801]).to eq "\n"
  end

  it 'deve ser possivel adicionar mais de um pagamento' do
    objeto.pagamentos << pagamento
    remessa = objeto.gera_arquivo

    expect(remessa.size).to eq 1603
  end
end
