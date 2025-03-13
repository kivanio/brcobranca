# frozen_string_literal: true

shared_examples_for 'cnab400 PIX' do
  let(:pagamento) do
    Brcobranca::Remessa::PagamentoPix.new(
      valor: 199.9,
      data_vencimento: Date.current,
      nosso_numero: 123,
      documento_sacado: '12345678901',
      nome_sacado: 'PABLO DIEGO JOSÉ FRANCISCO,!^.?\/@  DE PAULA JUAN NEPOMUCENO MARÍA DE LOS REMEDIOS CIPRIANO DE LA SANTÍSSIMA TRINIDAD RUIZ Y PICASSO',
      endereco_sacado: 'RUA RIO GRANDE DO SUL,!^.?\/@ São paulo Minas caçapa da silva junior',
      bairro_sacado: 'São josé dos quatro apostolos magros',
      cep_sacado: '12345678',
      cidade_sacado: 'Santa rita de cássia maria da silva',
      nome_avalista: 'ISABEL CRISTINA LEOPOLDINA ALGUSTA MIGUELA GABRIELA RAFAELA GONZAGA DE BRAGANÇA E BOURBON',
      uf_sacado: 'SP',
      tipo_chave_pix: 'cpf',
      chave_pix: '12345678910',
      tipo_pagamento_pix: '00',
      quantidade_pagamentos_pix: 1,
      tipo_valor_pix: '2', # 1 - percentual, 2 - valor
      valor_maximo_pix: 199.9,
      percentual_maximo_pix: 100.0,
      valor_minimo_pix: 199.9,
      percentual_minimo_pix: 100.0,
      txid_pix: nil
    )
  end

  let(:params) do
    if subject.instance_of?(Brcobranca::Remessa::Cnab400::SantanderPix)
      {
        codigo_transmissao: '17777751042700080112',
        empresa_mae: 'SOCIEDADE BRASILEIRA DE ZOOLOGIA LTDA',
        documento_cedente: '12345678910',
        agencia: '8888',
        conta_corrente: '000002997',
        digito_conta: '8',
        pagamentos: [pagamento]
      }
    else
      { carteira: '123',
        agencia: '1234',
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
    expect { objeto.monta_detalhe(Brcobranca::Remessa::PagamentoPix.new, 1) }.to raise_error(Brcobranca::RemessaInvalida)
  end

  it 'detalhe deve ter 400 posicoes' do
    expect(objeto.monta_detalhe(pagamento, 1).size).to eq 400
  end

  context 'trailer' do
    it 'trailer deve ter 400 posicoes' do
      expect(objeto.monta_trailer(1).size).to eq 400
    end

    it 'informacoes devem estar posicionadas corretamente no trailer' do
      trailer = objeto.monta_trailer 4
      expect(trailer[0]).to eq '9' # identificacao registro

      if subject.instance_of?(Brcobranca::Remessa::Cnab400::SantanderPix)
        expect(trailer[1..6]).to eq '000004'                # numero sequencial do registro
        expect(trailer[7..19]).to eq '0000000019990'        # total
        expect(trailer[20..393]).to eq ''.rjust(374, '0')   # zeros
      else
        expect(trailer[1..393]).to eq ''.rjust(393, ' ')    # brancos
      end

      expect(trailer[394..399]).to eq '000004' # numero sequencial do registro
    end
  end

  it 'montagem da remessa deve falhar se o objeto nao for valido' do
    expect { subject.class.new.gera_arquivo }.to raise_error(Brcobranca::RemessaInvalida)
  end

  it 'remessa deve conter os registros mais as quebras de linha' do
    remessa = objeto.gera_arquivo
    expect(remessa.size).to eq 1608

    # registros
    expect(remessa[0..399]).to eq objeto.monta_header
    expect(remessa[402..801]).to eq objeto.monta_detalhe(pagamento, 2).upcase
    expect(remessa[804..1203]).to eq objeto.monta_detalhe_pix(pagamento, 3)
    expect(remessa[1206..1605]).to eq objeto.monta_trailer(4)
    # quebras de linha
    expect(remessa[400..401]).to eq "\r\n"
    expect(remessa[802..803]).to eq "\r\n"
    expect(remessa[1204..1205]).to eq "\r\n"
  end

  it 'deve ser possivel adicionar mais de um pagamento' do
    objeto.pagamentos << pagamento
    remessa = objeto.gera_arquivo

    expect(remessa.size).to eq 2412
  end
end
