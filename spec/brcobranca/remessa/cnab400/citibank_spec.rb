# -*- encoding: utf-8 -*-
require 'spec_helper'

RSpec.describe Brcobranca::Remessa::Cnab400::Citibank do
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
    {
      portfolio: '17777751042700080112',
      carteira: '1',
      empresa_mae: 'asd',
      documento_cedente: '12345678910',
      pagamentos: [pagamento]
    }
  end
  let(:citibank_cnab400) { subject.class.new(params) }

  context 'validacoes dos campos' do
    context '@carteira' do
      it 'deve ser invalido se nao possuir uma carteira' do
        object = subject.class.new(params.merge!(carteira: nil))
        expect(object.invalid?).to be true
        expect(object.errors.full_messages).to include('Carteira não pode estar em branco.')
      end

      it 'deve ser invalido se a carteira tiver mais de 3 digitos' do
        citibank_cnab400.carteira = '1234'
        expect(citibank_cnab400.invalid?).to be true
        expect(citibank_cnab400.errors.full_messages).to include('Carteira deve ter no máximo 1 dígito.')
      end
    end

    context '@documento_cedente' do
      it 'deve ser invalido se nao possuir o documento cedente' do
        object = subject.class.new(params.merge!(documento_cedente: nil))
        expect(object.invalid?).to be true
        expect(object.errors.full_messages).to include('Documento cedente não pode estar em branco.')
      end

      it 'deve ser invalido se o documento do cedente nao tiver entre 11 e 14 digitos' do
        citibank_cnab400.documento_cedente = '123'
        expect(citibank_cnab400.invalid?).to be true
        expect(citibank_cnab400.errors.full_messages).to include('Documento cedente deve ter entre 11 e 14 dígitos.')
      end
    end

    context '@portfolio' do
      it 'deve ser invalido se nao possuir o portfolio' do
        object = subject.class.new(params.merge!(portfolio: nil))
        expect(object.invalid?).to be true
        expect(object.errors.full_messages).to include('Portfolio não pode estar em branco.')
      end

      it 'deve ser invalido se o deve ter no máximo 20 dígitos.' do
        citibank_cnab400.portfolio = '123456789012345678901'
        expect(citibank_cnab400.invalid?).to be true
        expect(citibank_cnab400.errors.full_messages).to include('Portfolio deve ter no máximo 20 dígitos.')
      end
    end
  end

  context 'formatacoes dos valores' do
    it 'cod_banco deve ser 341' do
      expect(citibank_cnab400.cod_banco).to eq '745'
    end

    it 'nome_banco deve ser CITIBANK' do
      nome_banco = citibank_cnab400.nome_banco
      expect(nome_banco.strip).to eq 'CITIBANK'
    end

    it 'complemento deve retornar 294 caracteres' do
      expect(citibank_cnab400.complemento.size).to eq 294
    end

    it 'info_conta deve retornar com 20 posicoes as informacoes da conta' do
      info_conta = citibank_cnab400.info_conta
      expect(info_conta.size).to eq 20
      expect(info_conta[0..19]).to eq '17777751042700080112'   # portfolio
    end
  end

  context 'monta remessa' do
    it_behaves_like 'cnab400'

    context 'header' do
      it 'informacoes devem estar posicionadas corretamente no header' do
        header = citibank_cnab400.monta_header
        expect(header[1]).to eq '1'                            # tipo operacao (1 = remessa)
        expect(header[2..8]).to eq 'REMESSA'                   # literal da operacao
        expect(header[26..45]).to eq citibank_cnab400.info_conta   # informacoes da conta
        expect(header[76..78]).to eq '745'                     # codigo do banco
      end
    end

    context 'detalhe' do
      it 'informacoes devem estar posicionadas corretamente no detalhe' do
        detalhe = citibank_cnab400.monta_detalhe pagamento, 1
        expect(detalhe[64..75]).to eq '000000000123'                       # nosso numero
        expect(detalhe[120..125]).to eq Date.today.strftime('%d%m%y')  # data de vencimento
        expect(detalhe[126..138]).to eq '0000000019990'                # valor do titulo
        expect(detalhe[220..233]).to eq '00012345678901'               # documento do pagador
        expect(detalhe[234..263]).to eq 'NOME'.ljust(30, ' ')          # nome do pagador
      end
    end
  end
end
